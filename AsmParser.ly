> {
> module AsmParser where
> import Data.Char
> }

> %name asm
> %tokentype { Token }

The parser will be of type [Token] -> ?, where ? is determined by the
production rules.  Now we declare all the possible tokens:

> %token 
	ADD     { TokenADD }
	ADDC    { TokenADDC }
	SUBB    { TokenSUBB }
	INC     { TokenINC }
	DEC     { TokenDEC }
	MUL     { TokenMUL }
	DIV     { TokenDIV }
	DA      { TokenDA }
	ANL     { TokenANL }
	ORL     { TokenORL }
	XRL     { TokenXRL }
	CLR     { TokenCLR }
	CPL     { TokenCPL }
	RL      { TokenRL }
	RLC     { TokenRLC }
	RR      { TokenRR }
	RRC     { TokenRRC }
	SWAP    { TokenSWAP }
	MOV     { TokenMOV }
	MOVC    { TokenMOVC }
	MOVX    { TokenMOVX }
>	push    { TokenPUSH }
>	pop     { TokenPOP }
	XCH     { TokenXCH }
	XCHD    { TokenXCHD }
>	acall   { TokenACALL }
>	lcall   { TokenLCALL }
>	ret     { TokenRET }
>	reti    { TokenRETI }
>	ajmp    { TokenAJMP }
>	ljmp    { TokenLJMP }
>	sjmp    { TokenSJMP }
>	jmp     { TokenJMP }
>	jz      { TokenJZ }
>	jnz     { TokenJNZ }
>	jc      { TokenJC }
>	jnc     { TokenJNC }
>	jb      { TokenJB }
>	jnb     { TokenJNB }
>	jbc     { TokenJBC }
>	cjne    { TokenCJNE }
>	djnz    { TokenDJNZ }
	NOP     { TokenNOP }
	CLR     { TokenCLR }
	SETB    { TokenSETB }
>	label   { TokenLABEL $$ }
>	other   { TokenOTHER $$ }
>	eol     { TokenEOL }
>	','     { TokenCOMMA }


> %%

Now we have the production rules.
> Program :: { Program }
> Program : BlockList           { Program $1 }
> BlockList :: { [Block] }
> BlockList : {- empty -}       { [] }
> BlockList : Block BlockList   { $1:$2 }
> Block :: { Block }
> Block : label eol InstrList   { Block $1 $3 }
> InstrList :: { [Instr] }
> InstrList : {- empty -}       { [] }
> InstrList : Instr InstrList   { $1:$2 }
> Instr :: { Instr }
> Instr : push other eol        { Push $2 }
> Instr : pop  other eol        { Pop $2 }
> Instr : ret eol               { Ret }
> Instr : reti eol              { Reti }
> Instr : other ArgList eol       { Other $1 $2 }
> Instr : acall other eol       { Acall $2 }
> Instr : lcall other eol       { Lcall $2 }
> Instr : ajmp other eol        { Ajmp $2 }
> Instr : ljmp other eol        { Ljmp $2 }
> Instr : sjmp other eol        { Sjmp $2 }
> Instr : jmp other eol         { Jmp $2 }
> Instr : jz other eol          { Jz $2 }
> Instr : jnz other eol         { Jnz $2 }
> Instr : jc other eol          { Jc $2 }
> Instr : jnc other eol         { Jnc $2 }
> Instr : jb other ',' other eol          { Jb $2 $4 }
> Instr : jnb other ',' other eol         { Jnb $2 $4 }
> Instr : jbc other ',' other eol         { Jbc $2 $4 }
> Instr : cjne other ',' other ',' other eol        { Cjne $2 $4 $6 }
> Instr : djnz other ',' other eol        { Djnz $2 $4 }
> ArgList :: { [AsmArg] }
> ArgList : {- empty -}         { [] }
> ArgList : ArgListNe           { $1 }
> ArgListNe :: { [AsmArg] }
> ArgListNe : other       { [$1] }
> ArgListNe : other ',' ArgListNe     { $1 : $3 }
> {

> happyError :: [Token] -> a
> happyError _ = error ("Parse error\n")

Now we declare the datastructure that we are parsing.
> type AsmArg = String
> type Label = String
> data Instr
>        = Push AsmArg 
>        | Pop AsmArg
>        | Ret
>        | Reti
>        | Acall {jmpRel :: AsmArg} 
>        | Lcall {jmpRel :: AsmArg}
>        | Ajmp {jmpRel :: AsmArg}
>        | Ljmp {jmpRel :: AsmArg}
>        | Sjmp {jmpRel :: AsmArg}
>        | Jmp {jmpRel :: AsmArg}
>        | Jz {jmpRel :: AsmArg}
>        | Jnz {jmpRel :: AsmArg}
>        | Jc {jmpRel :: AsmArg}
>        | Jnc {jmpRel :: AsmArg}
>        | Jb {jmpCond :: AsmArg, jmpRel :: AsmArg}
>        | Jnb {jmpCond :: AsmArg, jmpRel :: AsmArg}
>        | Jbc {jmpCond :: AsmArg, jmpRel :: AsmArg}
>        | Cjne {jmpCond :: AsmArg, jmpCond2 :: AsmArg, jmpRel :: AsmArg}
>        | Djnz {jmpCond :: AsmArg, jmpRel :: AsmArg}
>        | Other AsmArg [AsmArg]
>     deriving Show
>
> data Block = Block Label [Instr]
>     deriving Show
> data Program = Program [Block]
>     deriving Show


> data Token
>       = TokenPUSH
>       | TokenEOL
>       | TokenPOP
>       | TokenRET
>       | TokenRETI
>       | TokenACALL 
>       | TokenLCALL
>       | TokenAJMP
>       | TokenLJMP
>       | TokenSJMP
>       | TokenJMP
>       | TokenJZ
>       | TokenJNZ
>       | TokenJC
>       | TokenJNC
>       | TokenJB
>       | TokenJNB
>       | TokenJBC
>       | TokenCJNE
>       | TokenDJNZ
>       | TokenLABEL String
>       | TokenOTHER String
>       | TokenCOMMA 
>   deriving Show
>
> isNewLine = flip elem "\n\r"
>
> lexer :: String -> [Token]
> lexer [] = []
> lexer (c:cs) 
>    | c == ',' = TokenCOMMA:lexer cs
>    | isNewLine c = lexControl (c:cs)
>    | isSpace c = lexer cs
>    | otherwise = lexVar (c:cs)

> lexControl :: String -> [Token]
> lexControl cs =
>   let (a,r) = span (isNewLine) cs
>   in TokenEOL:(lexer r)

> lexVar :: String -> [Token]
> lexVar cs =
>    let (a,r) = span (not . isSpace) cs
>     in case a of
>           "push"  -> TokenPUSH:(lexer r)
>           "pop"   -> TokenPOP:(lexer r)
>           "ret"   -> TokenRET:(lexer r)
>           "reti"  -> TokenRETI:(lexer r)
>           "acall" -> TokenACALL:(lexer r)
>           "lcall" -> TokenLCALL:(lexer r)
>           "ajmp"  -> TokenAJMP:(lexer r)
>           "ljmp"  -> TokenLJMP:(lexer r)
>           "sjmp"  -> TokenSJMP:(lexer r)
>           "jmp"   -> TokenJMP:(lexer r)
>           "jz"    -> TokenJZ:(lexer r)
>           "jnz"   -> TokenJNZ:(lexer r)
>           "jc"    -> TokenJC:(lexer r)
>           "jnc"   -> TokenJNC:(lexer r)
>           "jb"    -> TokenJB:(lexer r)
>           "jnb"   -> TokenJNB:(lexer r)
>           "jbc"   -> TokenJBC:(lexer r)
>           "cjne"  -> TokenCJNE:(lexer r)
>           o       -> if last o == ':'
>                        then ((TokenLABEL . init) o):(lexer r)
>                        else lexOther (a ++ r)
>
> lexOther cs = lexOther' False cs ""
>   where
>     lexOther' _ [] acc = [TokenOTHER acc]
>     lexOther' False (c:cs) acc
>         | c == ',' = (TokenOTHER acc):lexer (c:cs)
>         | isSpace c = (TokenOTHER acc):lexer (c:cs)
>         | c == '(' = lexOther' True cs (acc ++ [c])
>         | otherwise = lexOther' False cs (acc ++ [c])
>     lexOther' True (c:cs) acc
>         | c == ')' = lexOther' False cs (acc ++ [c])
>         | otherwise = lexOther' True cs (acc ++ [c])
> }
