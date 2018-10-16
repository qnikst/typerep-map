{-# LANGUAGE DataKinds            #-}
{-# LANGUAGE ExplicitNamespaces   #-}
{-# LANGUAGE KindSignatures       #-}
{-# LANGUAGE PolyKinds            #-}
{-# LANGUAGE TypeFamilies         #-}
{-# LANGUAGE TypeOperators        #-}
{-# LANGUAGE UndecidableInstances #-}

{-# OPTIONS_GHC -fplugin GHC.TypeLits.KnownNat.Solver #-}

module CacheMap
       ( spec
       ) where

import Criterion.Main (bench, nf, whnf, env)
import Common

import Prelude hiding (lookup)

import Data.Maybe (fromJust)
import Data.Proxy (Proxy (..))
import Data.Typeable (Typeable)
import GHC.Exts (fromList)
import GHC.TypeLits

import Data.TypeRepMap.Internal (TypeRepMap (..), WrapTypeable (..), lookup, insert, empty)

spec :: BenchSpec
spec = BenchSpec
  { benchLookup = Just $ \name ->
      env (mkMap 10000) $ \ ~bigMap ->
        bench name $ nf tenLookups bigMap
  , benchInsertSmall = Just $ \name -> 
      bench name $ whnf (inserts empty 10) (Proxy @ 99999)
  , benchInsertBig = Just $ \name ->
      env (mkMap 10000) $ \ ~(bigMap) ->
       bench name $ whnf (inserts bigMap 1) (Proxy @ 99999)
  , benchUpdateSmall = Just $ \name ->
      env (mkMap 10) $ \ ~(smallMap) ->
      bench name $ whnf (inserts smallMap 10) (Proxy @ 0)
  , benchUpdateBig = Just $ \name ->
      env (mkMap 10000) $ \ ~(bigMap) ->
        bench name $ whnf (inserts bigMap 10) (Proxy @ 0)
  }

tenLookups :: TypeRepMap (Proxy :: Nat -> *)
           -> ( Proxy 10, Proxy 20, Proxy 30, Proxy 40
              , Proxy 50, Proxy 60, Proxy 70, Proxy 80
              )
tenLookups tmap = (lp, lp, lp, lp, lp, lp, lp, lp)
  where
    lp :: forall (a::Nat). Typeable a => Proxy a
    lp = fromJust $ lookup tmap

inserts :: forall a . (KnownNat a)
        => TypeRepMap (Proxy :: Nat -> *)
        -> Int
        -> Proxy (a :: Nat)
        -> TypeRepMap (Proxy :: Nat -> *)
inserts !c 0 _ = c
inserts !c n x = inserts
   (insert x c)
   (n-1)
   (Proxy :: Proxy (a+1))

mkMap :: Int -> IO (TypeRepMap (Proxy :: Nat -> *))
mkMap n = pure $ fromList $ buildBigMap n (Proxy :: Proxy 0) []


buildBigMap :: forall a . (KnownNat a)
            => Int
            -> Proxy (a :: Nat)
            -> [WrapTypeable (Proxy :: Nat -> *)]
            -> [WrapTypeable (Proxy :: Nat -> *)]
buildBigMap 1 x = (WrapTypeable x :)
buildBigMap n x = (WrapTypeable x :) . buildBigMap (n - 1) (Proxy :: Proxy (a + 1))
