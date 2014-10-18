{-# LANGUAGE NoImplicitPrelude #-}

module Language.Dash.Environment (
  Environment (..),
  Literal (..),
  Term (..),
  getEnv
  ) where

import Data.Monoid
import Prelude (String,  (++), lookup, Maybe)
import Prelude (Show (show))
import Prelude (Bool, Int)

data Environment = Environment [(String, Literal)] deriving (Show)

instance Monoid Environment where
  mempty = Environment []
  mappend (Environment x) (Environment y) = Environment (x ++ y)

data Literal
  = LiteralString String
  | LiteralInt Int
  | LiteralBool Bool
  | LiteralFunction Environment (Maybe Literal -> Maybe Literal)

instance Show Literal where
  show (LiteralString s)     = show s
  show (LiteralInt i)        = show i
  show (LiteralBool b)       = show b
  show (LiteralFunction _ _) = "<function>"

data Term
  = Variable String
  | Apply Term Term
  | Lambda String Term
  | Literal Literal
  | If Term Term Term
  | LetRec String Term Term  -- TODO: List
  deriving (Show)

getEnv :: Environment -> String -> Maybe Literal
getEnv (Environment e) s = lookup s e
