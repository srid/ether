{-# LANGUAGE CPP #-}

#if __GLASGOW_HASKELL__ < 710
{-# LANGUAGE OverlappingInstances #-}
{-# OPTIONS_GHC -fno-warn-unrecognised-pragmas #-}
#endif

{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE PolyKinds #-}

-- | See "Control.Monad.Except".

module Control.Monad.Ether.Except.Class
    ( MonadExcept(..)
    ) where

import qualified Control.Monad.Trans.Ether.Except as E
import qualified Control.Monad.Trans.Lift.Catch as Lift


-- | See 'Control.Monad.Except.MonadError'.
class Monad m => MonadExcept tag e m | m tag -> e where

    -- | Is used within a monadic computation to begin exception processing.
    throw :: proxy tag -> e -> m a

    -- | A handler function to handle previous exceptions and return to
    -- normal execution.
    catch :: proxy tag -> m a -> (e -> m a) -> m a

instance (Monad m, e ~ e') => MonadExcept tag e (E.ExceptT tag e' m) where
    throw = E.throw
    catch = E.catch

instance {-# OVERLAPPABLE #-}
         ( Lift.LiftCatch t
         , Monad (t m)
         , MonadExcept tag e m
         ) => MonadExcept tag e (t m) where
    throw t = Lift.lift . throw t
    catch t = Lift.liftCatch (catch t)
