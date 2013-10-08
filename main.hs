module Main where

import System.Environment
import Control.Applicative
import Data.Maybe
import Control.Monad.State.Lazy
import Control.Monad.Error
import Control.Monad.Identity
import Control.Monad

import AsmParser
import Graph
import GraphAlg

import qualified Data.Map as M

doAnal p = parseProgram p >>= removeDuplicateEdges >>= connectZero >>= removeZeroCycles >>= stackAnal

printResult :: Trans (M.Map Label Int) -> IO ()
printResult t = do
    let (res, warnings) = runIdentity $ runStateT (runErrorT t) []
    printWarnings warnings
    printResult' res
printWarnings :: [String] -> IO ()
printWarnings = mapM_ $ \h -> putStr ("WARNING: " ++ h ++ "\n")
printResult' (Left msg) = putStr $ "ERROR: " ++ msg
printResult' (Right m) = printProgram m >> printInterrupt m

printProgram :: M.Map Label Int -> IO ()
printProgram = printKey "__sdcc_program_startup"

printInterrupt :: M.Map Label Int -> IO ()
printInterrupt = printKey "__interrupts"

printKey :: Label -> M.Map Label Int -> IO ()
printKey k m = putStr $ (show k) ++ ": " ++ res ++ "\n" where
    res = fromMaybe "--" (show <$> (M.lookup k m))

printProg :: Program -> IO ()
printProg = printResult . doAnal

main = do
    args <- getArgs
    case args of
        [] -> getContents >>= printProg . asm . lexer
        _:_:t -> fail "Too many arguments"
        [a] -> readFile a >>= printProg . asm . lexer

