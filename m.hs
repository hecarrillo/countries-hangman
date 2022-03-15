import System.IO
import System.Random (randomRIO)

{-- Para correr el codigo desde Shell:
cabal new-update
cabal new-install --lib --package-env . random
ghci
--}

type WordList = [String]

allPlaces :: IO WordList
allPlaces = do tempList <- readFile "./places.txt"
               return $ lines tempList

filterLength :: String -> Int -> Int -> Bool
filterLength word min max = length word >= min && length word <= max

gamePlaces :: WordList
gamePlaces = do allAvailable <- allPlaces
                return $ filter (\place -> filterLength place 5 10) allAvailable

randomPlaceGen :: WordList -> IO String
randomPlaceGen gp = do randomIdx <- randomRIO(0, length gp - 1)
                       return $ gp !! randomIdx 

randomPlace :: IO String
randomPlace = do rp <- gamePlaces
                 randomPlaceGen rp

hangman :: IO ()
hangman = do putStrLn "Bienvenido a 'Adivina el nombre del Lugar'"
             introduction (\z -> length z)
             
introduction :: (String -> Int) -> IO ()
introduction lengthWord = do word <- randomPlace
                             let count1 = lengthWord word
                             putStrLn ("Tiene " ++ (show (lengthWord word)) ++ " letras")
                             putStrLn ("Tienes " ++ (show ((lengthWord word) + 1)) ++ " intentos")
                             putStrLn "Trata de adivinarlo:"
                             play word 0 count1

sgetLine :: IO String
sgetLine = do x <- getCh
              if x == '\n' then
                 do putChar x
                    return []
              else
                 do putChar '-'
                    xs <- sgetLine
                    return (x:xs)

getCh :: IO Char
getCh = do hSetEcho stdin False
           x <- getChar
           hSetEcho stdin True
           return x

play :: String -> Int -> Int -> IO ()
play word tries maxTries = do putStr "? "
                              guess <- getLine
                              if triesf tries maxTries then
                                do putStrLn "Se acabaron tus intentos!"
                                   putStrLn ("El pais era: " ++ word)
                              else 
                                 if guess == word then
                                  putStrLn "Ganaste!!"
                                  else
                                    do putStrLn (match word guess)
                                       putStrLn ("Intento " ++ show(tries + 1) ++ "/" ++ show(maxTries + 1))
                                       play word (tries + 1) maxTries

triesf :: Int -> Int -> Bool
triesf tries maxTries = tries >= maxTries

match :: String -> String -> String
match xs ys = [if x `elem` ys then x else '-' | x <- xs]
