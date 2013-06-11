module Main where

import System.Environment

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
printWarnings [] = return ()
printWarnings (h:t) = putStr ("WARNING: " ++ h ++ "\n") >> printWarnings t
printResult' (Left msg) = putStr $ "ERROR: " ++ msg
printResult' (Right m) = printProgram m >> printInterrupt m

printProgram :: M.Map Label Int -> IO ()
printProgram = printKey "__sdcc_program_startup"

printInterrupt :: M.Map Label Int -> IO ()
printInterrupt = printKey "__interrupts"

printKey :: Label -> M.Map Label Int -> IO ()
printKey k m = do
    let x = M.lookup k m
    putStr $ (show k) ++ ": "
    case x of
        Nothing -> putStr "--"
        Just a -> putStr $ show a
    putStr "\n"
    return ()

printProg :: Program -> IO ()
printProg p= do
    let res = doAnal p
    printResult res
    return ()

main = do
    args <- getArgs
    case args of
        [] -> fail "No input file given"
        _:_:t -> fail "Too many arguments"
        [a] -> readFile a >>= \x -> printProg ((asm . lexer) x)

