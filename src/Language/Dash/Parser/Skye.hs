module Language.Dash.Parser.Skye where

import Control.Monad (void)
import Text.Parser.Char
import Text.Parser.Combinators
import Text.Trifecta

import Language.Dash.Types

typeBool :: Parser Type
typeBool = string "bool" >> return TBool

typeNat :: Parser Type
typeNat = string "nat" >> return TNat

function :: Parser Type -> Parser Type
function p = p `chainr1` (string "=>" >> return TAbs)

type' :: Parser Type
type' = function $ choice [typeBool, typeNat]

variable :: Parser (String, Type)
variable = do
  first <- lower
  name <- many alphaNum
  _ <- char ':'
  ty <- type' <* many space
  return (first:name, ty)

--variableList :: Parser [Term]
--variableList = fmap (fmap Var) (some variable)

endOfExpr :: Parser ()
endOfExpr = void $ char '.'

-- | Anonymous function.
--
-- e.g. @fun x y := x.@
fun :: Parser Term
fun = do
  _ <- string "fun"
  _ <- some space
  variables <- some variable
  _ <- string ":="
  _ <- many space
  body <- expr --manyTill anyChar (try endOfExpr)
  return $ foldr (uncurry Abs) body variables

bool :: Parser Term
bool = do
  x <- choice [ string "!t"
              , string "!f"
              ]
  case x of
    "!t" -> return TTrue
    "!f" -> return TFalse
    _ -> fail "Boolean should be '!t' or '!f'"

nat :: Parser Term
nat = Nat . read <$> some digit

expr :: Parser Term
expr = do
  _ <- spaces
  choice [ fun
         , fmap (Var . fst) variable
         , bool
         , nat]
