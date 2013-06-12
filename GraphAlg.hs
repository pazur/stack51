module GraphAlg where

import Control.Applicative
import Control.Monad
import Control.Monad.Error
import Control.Monad.State
import Data.Maybe
import qualified Data.Map as M
import qualified Data.Graph as G
import qualified Data.Tree as T

import AsmParser
import Graph

type EdgeDict = M.Map (Maybe Label) Int

removeDuplicateEdges :: Graph -> GraphTrans
removeDuplicateEdges g = return $ map maxEdges g
maxEdges :: Vertex -> Vertex
maxEdges = maxEdgesRename Just

maxEdgesRename :: (Label -> Maybe Label) -> Vertex -> Vertex
maxEdgesRename r v = Vertex (label v) $ maxEdges' r v
maxEdges' :: (Label -> Maybe Label) -> Vertex -> [Edge]
maxEdges' r v = map (uncurry Edge) (M.toList (maxEdges'' r v))
maxEdges'' :: (Label -> Maybe Label) -> Vertex -> M.Map (Maybe Label) Int
maxEdges'' r (Vertex l e) = foldl (flip (maxEDict r l)) M.empty e

maxEDict :: (Label -> Maybe Label) -> Label -> Edge -> EdgeDict -> EdgeDict
maxEDict r vlabel (Edge to weight) = M.insertWith max (label >>= r) weight
      where label = fmap (\x -> if x == "." then vlabel else x) to

connectZero :: Graph -> GraphTrans
connectZero vs = let (g, vtn, ktv) = toGraph isZeroEdge vs
    in let sccs = map T.flatten (G.scc g)
        in return $ merge (map (toVert vtn) sccs)

--toGraph :: (Edge -> bool) -> [Vertex] -> ...
toGraph ef vs = G.graphFromEdges $ (Vertex "" [], "", []): map (toGraph' ef) vs
toGraph' :: (Edge -> Bool) -> Vertex -> (Vertex, Label, [Label])
toGraph' ef v = (v, label v, eds) where
    eds = map ((fromMaybe "") . edgeTo) (filter ef (edges v))

isZeroEdge :: Edge -> Bool
isZeroEdge (Edge _ x) = x == 0

toVert :: (G.Vertex -> (Vertex, key, [key])) -> [G.Vertex] -> Graph 
toVert f = map (fst3 . f)
    where fst3 (x, _, _) = x

merge :: [[Vertex]] -> [Vertex]
merge vss = map (merge' (rename vss)) vss
merge' :: M.Map Label Label -> [Vertex] -> Vertex
merge' m vs = maxEdgesRename (flip M.lookup m) vertex where
    Vertex fstlabel _ = head vs
    vertex = Vertex (m M.! fstlabel) (join (map edges vs))

rename :: [[Vertex]] -> M.Map Label Label
rename = rename' M.empty
rename' acc [] = acc
rename' acc (h:t) = rename' (foldl fun acc h) t where
    fun d x = M.insert (label x) (label (head h)) d

removeZeroCycles :: Graph -> GraphTrans
removeZeroCycles g = return $ map removeZeroCycles' g
removeZeroCycles' (Vertex l es) = Vertex l (filter f es) where
    f e = edgeTo e /= Just l || edgeWeight e /= 0


checkCycles :: Graph -> GraphTrans
checkCycles vs = checkLongCycles vs >> mapM_ checkSelfCycles vs >> return vs 
checkLongCycles :: Graph -> Trans ()
checkLongCycles vs = let (g, k, v) = toGraph (\x->True) vs
                     in if length (G.scc g) == 1 + (length vs)
                        then return ()
                        else fail "Cycle in the graph"
checkSelfCycles :: Vertex -> Trans ()
checkSelfCycles (Vertex l e) = mapM_ (checkSelfCycles' l)  e
checkSelfCycles' :: Label -> Edge -> Trans ()
checkSelfCycles' l (Edge el _) = if ((l==) <$> el) == Just True
                                  then fail ("Cycle in graph: " ++ l)
                                  else return ()

reverseGraph :: Graph -> GraphTrans
reverseGraph g = return $ reverseGraph' M.empty g
reverseGraph' :: M.Map (Maybe Label) [Edge] -> Graph -> Graph
reverseGraph' acc [] = map (uncurry (Vertex . (fromMaybe ""))) (M.toList acc)
reverseGraph' acc ((Vertex l es):t) = reverseGraph' (insEdges l acc es) t
insEdges :: Label -> M.Map (Maybe Label) [Edge] -> [Edge] -> M.Map (Maybe Label) [Edge]
insEdges l = foldl (\d (Edge v i) -> M.insertWith (++) v [Edge (Just l) i] d)

topSort :: Graph -> GraphTrans
topSort rg = let (g, k, _) = toGraph (\x -> True) rg
    in return $ toVert k (G.topSort g)

stackAnal :: Graph -> Trans (M.Map Label Int)
stackAnal g = reverseGraph g >>= topSort >>=  return . (stackAnal' M.empty)
stackAnal' acc [] = acc
stackAnal' acc ((Vertex l e):t) = stackAnal' (foldl f acc' e) t where
        acc' = M.insertWith max l 0 acc
        f d (Edge (Just l1) k) = M.insertWith max l1 (k+ (acc' M.! l)) d
