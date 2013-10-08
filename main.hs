module Main where

import System.Environment
import Control.Applicative
import Data.List
import Data.Maybe
import Control.Monad.State.Lazy
import Control.Monad.Error
import Control.Monad.Identity
import Control.Monad

import AsmParser
import Graph
import GraphAlg

import qualified Data.Map as M

doAnalX p = do
    g <- (parseProgram p >>= removeDuplicateEdges >>= connectZero >>= removeZeroCycles)
    m <- stackAnal g
    return (g, m)

printResultX :: Trans (Graph, M.Map Label Int) -> IO ()
printResultX t = do
    let (res, warnings) = runIdentity $ runStateT (runErrorT t) []
    printWarnings warnings
    printResultX' res
printResultX' (Left msg) = putStr $ "ERROR: " ++ msg
printResultX' (Right (g, m)) = printInterrupts m g

printWarnings :: [String] -> IO ()
printWarnings = mapM_ $ \h -> putStr ("WARNING: " ++ h ++ "\n")

printInterrupts :: M.Map Label Int -> Graph -> IO ()
printInterrupts m g = mapM_ (printKey m) (interruptsKeys g)

interruptsKeys :: Graph -> [Label]
interruptsKeys = catMaybes . (map edgeTo) . (fromMaybe []) . (fmap edges) . (find (("__interrupt_vect"==) . label))

printKey :: M.Map Label Int -> Label -> IO ()
printKey m k = putStr $ (show k) ++ ": " ++ res ++ "\n" where
    res = fromMaybe "--" (show <$> (M.lookup k m))

printProgX :: Program -> IO ()
printProgX = printResultX . doAnalX

main = do
    args <- getArgs
    case args of
        [] -> getContents >>= printProgX . asm . lexer
        _:_:t -> fail "Too many arguments"
        [a] -> readFile a >>= printProgX . asm . lexer

