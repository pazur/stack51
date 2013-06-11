module Graph where

import Control.Applicative
import Control.Monad
import Control.Monad.Error
import Control.Monad.Identity
import Control.Monad.State.Lazy
import Data.List
import Data.Maybe

import AsmParser

data Edge = Edge {edgeTo :: (Maybe Label), edgeWeight :: Int}
    deriving Show
data Vertex = Vertex {label::Label, edges::[Edge]}
    deriving Show
type Graph = [Vertex]
type RawTrans = StateT [String] Identity
type Trans = ErrorT String (RawTrans)
type GraphTrans = Trans Graph

callMem = 2

parseProgram :: Program -> GraphTrans
parseProgram (Program ll) = parseProgram' ll
parseProgram' :: [Block] -> GraphTrans
parseProgram' [] = return []
parseProgram' [b] = fmap (\x->[x]) (toVertex b Nothing)
parseProgram' (b1:b2:bs) = do
    head <- toVertex b1 (Just b2)
    tail <- parseProgram' (b2:bs)
    return $ head:tail

toVertex :: Block -> (Maybe Block) -> Trans Vertex
toVertex (Block l []) next = do
    e <- toNext 0 Nothing next 
    return $ Vertex l e 
toVertex (Block l instrs) next = do
    (res, (curr, max)) <- runStateT (sequence (map getEdge instrs)) (0,0)
    e1 <- toNext curr (last res) next
    let e2 = mapMaybe id res
    return $ Vertex l (e1 ++(Edge Nothing max):e2)

toNext :: Int -> Maybe Edge -> Maybe Block -> Trans[Edge]
toNext _ Nothing Nothing = return $ [] 
toNext s Nothing (Just (Block label _)) = return $ [Edge (Just label) s]
toNext _ _ _ = return $ []

getEdge :: Instr -> StateT (Int, Int) Trans (Maybe Edge)
getEdge (Push _) = do
    (s,m) <- get
    put (s+1,max (s+1) m)
    return Nothing
getEdge (Pop _) = modify (\(s,m)->(s-1,m)) >> return Nothing
getEdge Ret = doRet 
getEdge Reti = doRet 
getEdge (Acall a) = doCall a
getEdge (Lcall a) = doCall a
getEdge (Ajmp a) = doJmp a
getEdge (Ljmp a) = doJmp a
getEdge (Sjmp a) = doJmp a
getEdge (Jmp a) = doJmp a
getEdge (Jz a) = doJmp a
getEdge (Jnz a) = doJmp a
getEdge (Jc a) = doJmp a
getEdge (Jnc a) = doJmp a
getEdge (Jbc _ a) = doJmp a
getEdge (Cjne _ _ a) = doJmp a
getEdge (Djnz _ a) = doJmp a
getEdge (Other l as) = do
    if elem "SP" as
    then lift (modify (++["SP operations"]))
    else return ()
    return Nothing
getEdge _ = return Nothing

doRet :: StateT (Int, Int) Trans (Maybe Edge)
doRet = get >>= \x -> return $ Just $ Edge Nothing 0

doJmp :: AsmArg -> StateT (Int, Int) Trans (Maybe Edge)
doJmp arg = get >>= \x -> return $ Just $ Edge (Just arg) (fst x)

doCall :: AsmArg -> StateT (Int, Int) Trans (Maybe Edge)
doCall arg = get >>= \x -> return $ Just $ Edge (Just arg) (callMem + fst x)

