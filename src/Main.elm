module Main exposing (..)

import Array as Array
import Html exposing (..)
import Html.Events exposing (onClick)
import Browser exposing (sandbox)
import Bitwise exposing (shiftRightBy, shiftLeftBy, and)

type alias Model =
    { state : Array.Array Int
    , index : Int
    , randomNum : Int
    }

init : Model
init =
    { state = Array.fromList <| List.indexedMap (\idx _ -> idx) <| List.repeat 623 0
    , index = 0
    , randomNum = 0
    }

int32 : Int -> Int
int32 input =
    -- hex 0xFFFFFFFF
    Bitwise.and 0xFFFFFFFF (input)

generateNumbers : Model -> Model
generateNumbers model =
    let
        idxMapFunc : Int -> Int -> Int
        idxMapFunc idx currentElem =
            let
                nextElem = Array.get (modBy 624 <| idx + 1) model.state |> Maybe.withDefault 0
                y  = (Bitwise.and currentElem 0x80000000) + (Bitwise.and nextElem 0x7fffffff)

                newElem =
                    let
                        x = (Array.get (modBy 624 <| idx + 397) model.state|> Maybe.withDefault 0)
                    in
                        Bitwise.xor x (Bitwise.shiftRightBy 1 y)
            in
                if (modBy 2 y) /= 0 then
                    Bitwise.xor newElem 2567483615
                else
                    newElem
    in
        { model | state = Array.indexedMap idxMapFunc model.state }

pRandom : Float -> Float
pRandom t =
    if t <= 0 then
        42
    else
        let
            a = 
                2000 * t
                    |> String.fromFloat
                    |> String.filter (== ".")

        in

extractNumbers : Model -> Model
extractNumbers model =
    let
        newModel = if model.index == 0 then generateNumbers model else model

        y = (Array.get (newModel.index) newModel.state |> (Maybe.withDefault 0))
        _ = Debug.log "y" y
        a = Bitwise.xor y (shiftRightBy 11 y)
        _ = Debug.log "a" a
        b = Bitwise.xor a (Bitwise.and (shiftLeftBy 7 a) 2636928640)
        _ = Debug.log "b" b
        c = Bitwise.xor b (Bitwise.and (shiftLeftBy 15 b) 4022730752)
        _ = Debug.log "c" c
        d = Bitwise.xor c (shiftRightBy 18 y)
        _ = Debug.log "d" d

        newidx = modBy 624 <| newModel.index + 1
    in
        { newModel | index = newidx, randomNum = int32 d }

generateRandomNumber : Float -> Int
generateRandomNumber seed =
    let
        model =
            { state = Array.fromList <| List.indexedMap (\idx _ -> idx) <| List.repeat 624 0
            , index = 0
            , randomNum = 0
            }
            
        newState = 
            Array.set 0 (round seed) (Array.slice 0 5 model.state)

        idxMapFunc : Int -> Int -> Int
        idxMapFunc idx num =
            if idx /= 0 then
                let
                    foldFunc : (Int, Int) -> (Int, Int) -> (Int, Int)
                    foldFunc (index1, fstElem) (index2, lstElem) =
                    -- [(0, 1), (1, 1812433254), (2, 1812433255), (3, -670100787)]
                        ( index2, (1812433253 * (Bitwise.xor fstElem (Bitwise.shiftRightBy 30 fstElem) ) + index2 ))    

                    prevElem = 
                        Array.foldl foldFunc (0, round seed) (Array.indexedMap Tuple.pair <| Array.slice 1 idx newState)
                            |> Debug.log "foldFunc"
                            |> Tuple.second
                in
                    (1812433253 * (Bitwise.xor prevElem (Bitwise.shiftRightBy 30 prevElem) ) + idx )
                        |> int32
                        |> Debug.log ("num" ++ String.fromInt idx)
            else
                num

        newModel = 
            extractNumbers { model | state = (Array.indexedMap idxMapFunc newState), index = 0 }
    in
        newModel.randomNum

type Msg = 
      GenerateRandomNum Int
    | GenRand

update : Msg -> Model -> Model
update msg model =
    case msg of
        GenerateRandomNum seed ->
            let
                newState = Array.toList <| Array.set 0 seed model.state
                idxMapFunc : Int -> Int -> Int
                idxMapFunc idx num =
                    if idx /= 0 then
                        let
                            prevElem = 
                                (Array.get (idx - 1) model.state |> (Maybe.withDefault 0))
                        in
                            int32 <| (1812433253 * (Bitwise.xor prevElem (Bitwise.shiftRightBy 30 prevElem) ) + idx )
                    else
                        num
            in
                extractNumbers { model | state = Array.indexedMap idxMapFunc model.state, index = 0 }
        GenRand ->
            { model | randomNum = generateRandomNumber 1 }


view : Model -> Html Msg
view model =
    div [] 
        [ div [] [ text <| String.fromInt model.randomNum ]
        , button [ onClick GenRand ] [ text "GetRandomNum" ]
        ]

main : Program () Model Msg
main = 
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }

{-
int[0..623] MT
int index = 0
function initialize_generator(int seed) {
    i := 0
    MT[0] := seed 
    for i from 1 to 623 {
        MT[i] := last 32 bits of(1812433253 * (MT[i-1] xor (right shift by 30 bits(MT[i-1]))) + i)
    }
}
 
function extract_number() {
    if index == 0 {
        generate_numbers()
    }
    int y := MT[index]
    y := y xor (right shift by 11 bits(y))
    y := y xor (left shift by 7 bits(y) and (2636928640))
    y := y xor (left shift by 15 bits(y) and (4022730752))
    y := y xor (right shift by 18 bits(y))
    index := (index + 1) mod 624      return y
}
function generate_numbers() {
    for i from 0 to 623 {
        int y := (MT[i] & 0x80000000) + (MT[(i+1) mod 624] & 0x7fffffff)
        MT[i] := MT[(i + 397) mod 624] xor (right shift by 1 bit(y))
        if (y mod 2) != 0 {
            MT[i] := MT[i] xor (2567483615)
        }
    }
}
-}
