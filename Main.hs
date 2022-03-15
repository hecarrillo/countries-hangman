import System.IO
import System.Random (randomRIO)

{-- Para correr el codigo desde Shell:
cabal new-update
cabal new-install --lib --package-env . random
ghci
--}

type WordList = [String]

allPlaces :: IO WordList
allPlaces = do tempList <- readFile("./places.txt")
               return $ lines tempList

filterLength :: String -> Int -> Int -> Bool
filterLength word min max = length word >= min && length word <= max

gamePlaces :: IO WordList
gamePlaces = do allAvailable <- allPlaces
                return $ filter (\place -> filterLength place 5 10) allAvailable

randomPlaceGen :: WordList -> IO String
randomPlaceGen gp = do randomIdx <- randomRIO(0, length gp - 1)
                       return $ gp !! randomIdx 

randomPlace :: IO String
randomPlace = do rp <- gamePlaces
                 return $ randomPlaceGen rp

hangman :: IO ()
hangman = do putStrLn "Bienvenido a 'Adivina el Lugar'"
             word <- randomPlace
             let count1 = (\x -> length x) word
             introduction (\z -> length z) word
            -- putStrLn ("Tiene " ++ (show count1) ++ " letras")
             -- putStrLn ("Tienes " ++ (show (count1 + 1)) ++ " intentos")
             -- putStrLn "Trata de adivinarlo:"
             play word 0 count1

introduction :: (String -> Int) -> String -> IO ()
introduction lengthWord word = do putStrLn ("Tiene " ++ (show count1) ++ " letras")
                                  putStrLn ("Tienes " ++ (show (count1 + 1)) ++ " intentos")
                                  putStrLn "Trata de adivinarlo:"
                                



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
                              if tries >= maxTries then
                                do putStrLn "Se acabaron tus intentos!"
                                   putStrLn ("El pais era: " ++ word)
                              else 
                                 if guess == word then
                                  putStrLn "Ganaste!!"
                                  else
                                    do putStrLn (match word guess)
                                       play word (tries + 1) maxTries

match :: String -> String -> String
match xs ys = [if x `elem` ys then x else '-' | x <- xs]
