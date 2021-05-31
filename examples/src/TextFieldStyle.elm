module TextFieldStyle exposing (main)

import Browser
import Dropdown exposing (Dropdown, OutMsg(..), Placement(..))
import Element as El
import Html exposing (Html)


type alias Model =
    { personDropdown : Dropdown Person
    , selected : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { personDropdown =
            Dropdown.init
                |> Dropdown.id "person"
                |> Dropdown.optionsBy .name (List.sortBy .name people)
                |> Dropdown.filterType Dropdown.StartsWithThenContains
      , selected = ""
      }
    , Cmd.none
    )


type alias Person =
    { name : String
    , age : Int
    }


people : List Person
people =
    [ Person "John Doe" 78
    , Person "Jane Doe" 67
    , Person "Jim Smith" 45
    , Person "Alan Jones" 66
    , Person "Beatrice Davis" 56
    , Person "Candice Sands" 51
    , Person "Jason Smith" 34
    ]


type Msg
    = DropdownMsg (Dropdown.Msg Person)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DropdownMsg subMsg ->
            let
                ( dropdown, cmd, outMsg ) =
                    Dropdown.update subMsg model.personDropdown
            in
            ( { model
                | personDropdown = dropdown
                , selected =
                    case outMsg of
                        Selected ( _, name, _ ) ->
                            name

                        TextChanged _ ->
                            ""

                        _ ->
                            model.selected
              }
            , Cmd.map DropdownMsg cmd
            )


view : Model -> Html Msg
view model =
    El.layout
        [ El.padding 20 ]
        (El.row
            [ El.spacing 20 ]
            [ Dropdown.label (El.text "People") model.personDropdown
                |> Dropdown.inputType Dropdown.TextField
                |> Dropdown.labelPlacement Left
                |> Dropdown.view DropdownMsg
            , El.text ("Selected: " ++ model.selected)
            ]
        )


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
