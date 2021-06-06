module Dropdown exposing
    ( Dropdown, init, id
    , InputType(..), inputType
    , optionsBy, options, stringOptions, intOptions, floatOptions
    , label, labelHidden, buttonLabel
    , placeholder
    , Placement(..)
    , labelPlacement, labelSpacing
    , menuPlacement, menuSpacing
    , maxHeight, inputAttributes, menuAttributes, optionAttributes, optionHoverAttributes, optionSelectedAttributes
    , FilterType(..), filterType
    , setSelected, removeSelected, removeOption
    , openOnMouseEnter
    , selected, selectedOption, selectedLabel, isOpen
    , OutMsg(..), Msg, update
    , view
    )

{-| A dropdown component for
[Elm-UI](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/).

In order to provide built-in keyboard navigation, and option filtering, it is
necessary for the Dropdown to manage it's own internal state. Therefore any
Dropdowns you require need to be stored on your `Model`, with events being
handled in your `update` function.

There are a few gotchas to watch out for with functions that operate on the
internal state of the Dropdown. Because of the effect they have on the internal
state, using them in your `view` code will have no effect. They should
therefore be used when you [init](#init) the Dropdown, or in your `update`
function where model changes can be captured.

The affected functions are, [id](#id), [filterType](#filterType),
[setSelected](#setSelected), [removeSelected](#removeSelected),
[removeOption](#removeOption] & [openOnMouseEnter](#openOnMouseEnter), along
with all the functions for [setting the menu options](#setting-options). Each
function or section has a warning documenting this restriction where it's
applicable.

All other functions can be used safely within `view` code.


## Build


### Setting Up

@docs Dropdown, init, id


### Input Type

@docs InputType, inputType


### Setting Options

**Warning**

Options need to be stored on the dropdown model, and so should be set
when you [init](#init) the dropdown, or in your `update` function where the
changes to the model can be captured.

If you set these in your `view` code they will have no effect and so no menu
will appear.

@docs optionsBy, options, stringOptions, intOptions, floatOptions


### Label

@docs label, labelHidden, buttonLabel


### Placeholder

@docs placeholder


### Positioning

@docs Placement

@docs labelPlacement, labelSpacing

@docs menuPlacement, menuSpacing


### Size & Style

@docs maxHeight, inputAttributes, menuAttributes, optionAttributes, optionHoverAttributes, optionSelectedAttributes


### Filtering

Filtering is currently case insensitive.

@docs FilterType, filterType


### Selected Option

@docs setSelected, removeSelected, removeOption


### Controls

@docs openOnMouseEnter


## Query

@docs selected, selectedOption, selectedLabel, isOpen


## Update

@docs OutMsg, Msg, update


## View

@docs view

-}

import Browser.Dom as Dom
import Element as El exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Cursor as Cursor
import Element.Events as Event
import Element.Font as Font
import Element.Input as Input exposing (Placeholder)
import Html.Attributes as Attr
import Html.Events exposing (keyCode, on)
import Json.Decode as Json
import Process
import Task



{- Build -}


{-| An opaque type representing the internal model.

Use this to define the `option` type on your model.

    import Dropdown exposing (Dropdown)

    type alias Model =
        { stringDropdown : Dropdown String
        , intDropdown : Dropdown Int
        , customTypeDropdown : Dropdown CustomType
        }

    type CustomType
        = A
        | B
        ...

Interact with it with the following API.

-}
type Dropdown option
    = Dropdown
        { id : String
        , inputType : InputType
        , options : List (Option option)
        , filterType : FilterType
        , menuPlacement : Placement
        , menuSpacing : Int
        , label : Element (Msg option)
        , labelPlacement : Placement
        , labelSpacing : Int
        , labelHidden : ( Bool, String )
        , buttonLabel : Element (Msg option)
        , placeholder : Maybe (Placeholder (Msg option))
        , maxHeight : Int
        , inputAttributes : List (Attribute (Msg option))
        , menuAttributes : List (Attribute (Msg option))
        , optionAttributes : List (Attribute (Msg option))
        , optionHoverAttributes : List (Attribute (Msg option))
        , optionSelectedAttributes : List (Attribute (Msg option))
        , text : String
        , selected : Maybe (Option option)
        , hovered : Maybe (Option option)
        , show : Bool
        , openOnEnter : Bool
        , matchedOptions : List (Option option)
        , navType : Maybe NavType
        }


type alias Option option =
    ( Int, String, option )


type NavType
    = Keyboard
    | Mouse


{-| Initialize a dropdown on your model.

    import Dropdown

    initialModel : Model
    initialModel =
        { myDropdown = Dropdown.init }

-}
init : Dropdown option
init =
    Dropdown
        { id = ""
        , inputType = Button
        , options = []
        , filterType = NoFilter
        , menuPlacement = Below
        , menuSpacing = 0
        , label = El.text "Label"
        , labelPlacement = Above
        , labelSpacing = 10
        , labelHidden = ( False, "" )
        , buttonLabel =
            El.el
                [ El.centerX ]
                (El.text "-- Select --")
        , placeholder = Nothing
        , maxHeight = 150
        , inputAttributes = []
        , menuAttributes = []
        , optionAttributes = []
        , optionHoverAttributes = []
        , optionSelectedAttributes = []
        , text = ""
        , selected = Nothing
        , hovered = Nothing
        , show = False
        , openOnEnter = True
        , matchedOptions = []
        , navType = Nothing
        }


white : El.Color
white =
    El.rgb 1 1 1


black : El.Color
black =
    El.rgb 0 0 0


grey : El.Color
grey =
    El.rgb 0.5 0.5 0.5


{-| Provide an ID for the dropdown.

This will become the element `id` in the DOM, and is required in order for
keyboard navigation to work - it should therefore be unique.

    import Dropdown

    initialModel : Model
    initialModel =
        { myDropdown =
            Dropdown.init
                |> Dropdown.id "my-drodown"
        }

**Warning**

The `id` needs to be stored on the dropdown model, and so should be set
when you [init](#init) the dropdown, or in your `update` function where the
changes to the model can be captured.

If you set this in your `view` code it will have no effect and keyboard
navigation won't work.

-}
id : String -> Dropdown option -> Dropdown option
id id_ (Dropdown dropdown) =
    Dropdown { dropdown | id = id_ }


{-| This is the easiest way to set the options for custom types.

Simply provide a function that takes an `option` and returns the `String` to
be used for the label in the menu.

    import Dropdown exposing (Dropdown)

    type alias Model =
        { nameDropdown : Dropdown Person
        , ageDropdown : Dropdown Person
        }

    initialModel : Model
    initialModel =
        { nameDropdown =
            Dropdown.init
                |> Dropdown.optionsBy .name people
        , ageDropdown =
            Dropdown.init
                |> Dropdown.optionsBy (.age >> String.fromInt) people
        }

    type alias Person =
        { name : String
        , age : Int
        }

    people : List Person
    people =
        [ { name = "John Doe", age = 99 }
        , { name = "Jane Doe", age = 98 }
        ]

-}
optionsBy : (option -> String) -> List option -> Dropdown option -> Dropdown option
optionsBy accessorFunc options_ (Dropdown dropdown) =
    Dropdown
        { dropdown
            | options =
                List.indexedMap (\index option -> ( index, accessorFunc option, option )) options_
        }


{-| The options to set for your dropdown.

The first element in the list of tuples is always a `String`, and is used for
the option's label in the menu that is displayed to the user.

    import Dropdown exposing (Dropdown)

    type alias Model =
        { customTypeDropdown : Dropdown CustomType }

    initialModel : Model
    initialModel =
        { customTypeDropdown =
            Dropdown.init
                |> Dropdown.options customTypeOptions
        }

    type CustomType
        = A
        | B

    customTypeOptions : List ( String, CustomType )
    customTypeOptions =
        [ ( "A", A )
        , ( "B", B )
        ]

-}
options : List ( String, option ) -> Dropdown option -> Dropdown option
options options_ (Dropdown dropdown) =
    Dropdown
        { dropdown
            | options =
                List.indexedMap (\index ( label_, option ) -> ( index, label_, option )) options_
        }


{-| The options to set for your dropdown if they are all `String`s.

    import Dropdown exposing (Dropdown)

    type alias Model =
        { stringDropdown : Dropdown String }

    initialModel : Model
    initialModel =
        { stringDropdown =
            Dropdown.init
                |> Dropdown.stringOptions
                    [ "A"
                    , "B"
                    , "C"
                    ]
        }

-}
stringOptions : List String -> Dropdown String -> Dropdown String
stringOptions options_ =
    optionsBy identity options_


{-| The options to set for your dropdown if they are all `Int`s.

    import Dropdown exposing (Dropdown)

    type alias Model =
        { stringDropdown : Dropdown Int }

    initialModel : Model
    initialModel =
        { stringDropdown =
            Dropdown.init
                |> Dropdown.intOptions
                    [ 1
                    , 2
                    , 3
                    ]
        }

-}
intOptions : List Int -> Dropdown Int -> Dropdown Int
intOptions options_ =
    optionsBy String.fromInt options_


{-| The options to set for your dropdown if they are all `Float`s.

    import Dropdown exposing (Dropdown)

    type alias Model =
        { stringDropdown : Dropdown Float }

    initialModel : Model
    initialModel =
        { stringDropdown =
            Dropdown.init
                |> Dropdown.floatOptions
                    [ 0.1
                    , 0.2
                    , 0.3
                    ]
        }

-}
floatOptions : List Float -> Dropdown Float -> Dropdown Float
floatOptions options_ =
    optionsBy String.fromFloat options_


{-| The type of filter to apply when [TextField](#InputType) is used as the
[InputType](#InputType).

  - `NoFilter`: No filter will be applied.
  - `StartsWith`: Filter the list of options down to only those whose label
    starts with the entered text.
  - `Contains`: Filter the list of options down to only those whose label
    contains the entered text.
  - `StartsWithThenContains`: Filter the list of options down to only those
    whose label starts with the entered text or contains the entered text. The
    list of options will be sorted with `StartsWith` taking priority over
    `Contains`, with duplicates removed.

The default is `NoFilter`.

-}
type FilterType
    = NoFilter
    | StartsWith
    | Contains
    | StartsWithThenContains


{-| Set the `FiterType`.

    import Dropdown exposing (FilterType(..))

    initialModel : Model
    initialModel =
        { dropdown =
            Dropdown.init
                |> Dropdown.filterType StartsWith
        }

**Warning**

The `FilterType` needs to be stored on the dropdown model, and so should be set
when you [init](#init) the dropdown, or in your `update` function where the
changes to the model can be captured.

If you set this in your `view` code it will have no effect, and filtering won't
work.

-}
filterType : FilterType -> Dropdown option -> Dropdown option
filterType type_ (Dropdown dropdown) =
    Dropdown { dropdown | filterType = type_ }


{-| The type of input the user uses to access the dropdown.

The default is `Button`.

-}
type InputType
    = Button
    | TextField


{-| Set the `InputType`.
-}
inputType : InputType -> Dropdown option -> Dropdown option
inputType type_ (Dropdown dropdown) =
    Dropdown { dropdown | inputType = type_ }


{-| The position of the label or the dropdown menu in relation to the
[InputType](#InputType).
-}
type Placement
    = Above
    | Below
    | Left
    | Right


{-| Set the position of the dropdown menu in relation to the
[InputType](#InputType).

The default is [Below](#Placement).

-}
menuPlacement : Placement -> Dropdown option -> Dropdown option
menuPlacement placement (Dropdown dropdown) =
    Dropdown { dropdown | menuPlacement = placement }


{-| Set the spacing between the [InputType](#InputType) and the menu.

The default is 0.

-}
menuSpacing : Int -> Dropdown option -> Dropdown option
menuSpacing spacing (Dropdown dropdown) =
    Dropdown { dropdown | menuSpacing = spacing }


{-| Provide the label element for the [InputType](#InputType).
-}
label : Element (Msg option) -> Dropdown option -> Dropdown option
label label_ (Dropdown dropdown) =
    Dropdown { dropdown | label = label_ }


{-| Set the position of the label in relation to the [InputType](#InputType).

The default is [Above](#Placement).

-}
labelPlacement : Placement -> Dropdown option -> Dropdown option
labelPlacement placement (Dropdown dropdown) =
    Dropdown { dropdown | labelPlacement = placement }


{-| Set the spacing between the [InputType](#InputType) and its
[label](#label).

The default is 10.

-}
labelSpacing : Int -> Dropdown option -> Dropdown option
labelSpacing spacing (Dropdown dropdown) =
    Dropdown { dropdown | labelSpacing = spacing }


{-| Hide the [label](#label).
-}
labelHidden : ( Bool, String ) -> Dropdown option -> Dropdown option
labelHidden hidden (Dropdown dropdown) =
    Dropdown { dropdown | labelHidden = hidden }


{-| The text element for the [Button](#InputType) if nothing is selected.

The default is "-- Select --".

-}
buttonLabel : Element (Msg option) -> Dropdown option -> Dropdown option
buttonLabel label_ (Dropdown dropdown) =
    Dropdown { dropdown | buttonLabel = label_ }


{-| Provide the
[Placeholder](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/Element-Input#Placeholder)
for the text field if [TextField](#InputType) is the [InputType](#InputType).

The default is `Nothing`.

-}
placeholder : Maybe (Placeholder (Msg option)) -> Dropdown option -> Dropdown option
placeholder maybePlaceholder (Dropdown dropdown) =
    Dropdown { dropdown | placeholder = maybePlaceholder }


{-| The max height for the dropdown, the default is 150.

(Vertical scrolling kicks in automatically.)

-}
maxHeight : Int -> Dropdown option -> Dropdown option
maxHeight height (Dropdown dropdown) =
    Dropdown { dropdown | maxHeight = height }


{-| The
[Attributes](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/Element#Attribute)
to set on the [InputType](#InputType).
-}
inputAttributes : List (Attribute (Msg option)) -> Dropdown option -> Dropdown option
inputAttributes attrs (Dropdown dropdown) =
    Dropdown { dropdown | inputAttributes = attrs }


{-| The
[Attributes](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/Element#Attribute)
to set on the menu container.
-}
menuAttributes : List (Attribute (Msg option)) -> Dropdown option -> Dropdown option
menuAttributes attrs (Dropdown dropdown) =
    Dropdown { dropdown | menuAttributes = attrs }


{-| The
[Attributes](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/Element#Attribute)
to set on each option.
-}
optionAttributes : List (Attribute (Msg option)) -> Dropdown option -> Dropdown option
optionAttributes attrs (Dropdown dropdown) =
    Dropdown { dropdown | optionAttributes = attrs }


{-| The
[Attributes](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/Element#Attribute)
to set on an option when hovered over with the mouse, or navigated to with the
keyboard.
-}
optionHoverAttributes : List (Attribute (Msg option)) -> Dropdown option -> Dropdown option
optionHoverAttributes attrs (Dropdown dropdown) =
    Dropdown { dropdown | optionHoverAttributes = attrs }


{-| The
[Attributes](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/Element#Attribute)
to set on an option when it has been selected by a user.
-}
optionSelectedAttributes : List (Attribute (Msg option)) -> Dropdown option -> Dropdown option
optionSelectedAttributes attrs (Dropdown dropdown) =
    Dropdown { dropdown | optionSelectedAttributes = attrs }


{-| Set the selected option - it must exist in the list of
[options originally provided](#setting-options).

**Warning**

This function changes the internal state, and so needs to be used where the
state change can be captured. This is likely to be your `update` function.

If you use this in your `view` code it will have no effect.

-}
setSelected : Maybe option -> Dropdown option -> Dropdown option
setSelected maybeOption (Dropdown dropdown) =
    case maybeOption of
        Nothing ->
            Dropdown
                { dropdown
                    | selected = Nothing
                    , text = ""
                }

        Just option ->
            let
                maybeSelected =
                    List.filter (\( _, _, option_ ) -> option_ == option) dropdown.options
                        |> List.head
            in
            Dropdown
                { dropdown
                    | selected = maybeSelected
                    , text =
                        case maybeSelected of
                            Just ( _, label_, _ ) ->
                                label_

                            Nothing ->
                                ""
                }


{-| Remove the selected option of one dropdown from the list of options of
another dropdown.

This is useful if you have two dropdowns that show the same list of options,
but each selection must be unique, therefore you don't want to show the
selected option again.

For example, selecting a home team and away team from the same list of teams.
In this case, once the home team has been selected, you may wish to remove that
option from the list of away teams.

    Dropdown.removeSelected homeTeamDropdown awayTeamDropdown

**Warning**

This function changes the internal state, and so needs to be used where the
state change can be captured. This is likely to be your `update` function.

If you use this in your `view` code it will have no effect.

-}
removeSelected : Dropdown option -> Dropdown option -> Dropdown option
removeSelected (Dropdown dropdown) (Dropdown fromDropdown) =
    case dropdown.selected of
        Nothing ->
            Dropdown fromDropdown

        Just ( _, _, option ) ->
            Dropdown
                { fromDropdown
                    | options =
                        List.filter (\( _, _, option_ ) -> option /= option_) fromDropdown.options
                }


{-| Remove an `option` from the internal list.

**Warning**

This function changes the internal state, and so needs to be used where the
state change can be captured. This is likely to be your `update` function.

If you use this in your `view` code it will have no effect.

-}
removeOption : option -> Dropdown option -> Dropdown option
removeOption option (Dropdown dropdown) =
    Dropdown
        { dropdown
            | options =
                List.filter (\( _, _, option_ ) -> option /= option_) dropdown.options
            , matchedOptions =
                List.filter (\( _, _, option_ ) -> option /= option_) dropdown.matchedOptions
        }



{- Controls -}


{-| Choose whether the menu opens when the mouse enters.

If this is set to `True` the menu will also close automatically when the mouse
leaves.

The default is `True`.

**Warning**

This function changes the internal state, and so needs to be used where the
state change can be captured. This is likely to be your `update` function.

If you use this in your `view` code it will have no effect.

-}
openOnMouseEnter : Bool -> Dropdown option -> Dropdown option
openOnMouseEnter open (Dropdown dropdown) =
    Dropdown { dropdown | openOnEnter = open }



{- Queries -}


{-| Determine if an option has been selected by the user.

If a `Just` is returned, it consists of the following:

  - `Int`: The index of the selected option.
  - `String`: The label of the selected option.
  - `option`: The option value itself.

-}
selected : Dropdown option -> Maybe ( Int, String, option )
selected (Dropdown dropdown) =
    dropdown.selected


{-| Maybe retrieve the selected option.
-}
selectedOption : Dropdown option -> Maybe option
selectedOption =
    selected >> Maybe.map (\( _, _, option ) -> option)


{-| Maybe retrieve the label for the selected option.
-}
selectedLabel : Dropdown option -> Maybe String
selectedLabel =
    selected >> Maybe.map (\( _, label_, _ ) -> label_)


{-| Determine is the dropdown is open or not.
-}
isOpen : Dropdown option -> Bool
isOpen (Dropdown dropdown) =
    dropdown.show



{- Transform -}


toOptionId : Int -> String -> String
toOptionId index id_ =
    id_ ++ "-" ++ String.fromInt index



{- Update -}


{-| Pattern match on this type in your `update` function to determine the event
that occured.
-}
type OutMsg option
    = NoOp
    | Selected ( Int, String, option )
    | TextChanged String
    | FocusIn
    | FocusOut


{-| This is an opaque type, pattern match on [OutMsg](#OutMsg).
-}
type Msg option
    = OnMouseDown (Option option)
    | OnMouseMove (Option option)
    | OnMouseEnterOption (Option option)
    | OnMouseEnter
    | OnMouseLeave
    | OnChange String
    | BtnLabelFocus
    | GotFocus (Result Dom.Error ())
    | BtnClick
    | OnFocus
    | ShowMenu
    | OnLoseFocus
    | OnKeyDown Int
    | GetElement KeyDirection Int (Result Dom.Error Dom.Element)
    | GetViewport KeyDirection Int Float (Result Dom.Error Dom.Viewport)
    | PositionElement (Result Dom.Error ())


{-|

    import Dropdown exposing (OutMsg(..))

    type Msg
        = DropdownMsg Dropdown.Msg

    update : Msg -> Model -> ( Model, Cmd Msg )
    update msg model =
        case msg of
            DropdownMsg subMsg ->
                let
                    ( dropdown, cmd, outMsg ) =
                        Dropdown.update subMsg model.dropdown
                in
                case outMsg of
                    Selected ( index, label, option ) ->
                        ( { model | dropdown = dropdown }
                        , Cmd.map DropdownMsg cmd
                        )

                    TextChanged text ->
                        ( { model | dropdown = dropdown }
                        , Cmd.map DropdownMsg cmd
                        )

                    ...

-}
update : Msg option -> Dropdown option -> ( Dropdown option, Cmd (Msg option), OutMsg option )
update msg (Dropdown dropdown) =
    case msg of
        OnMouseDown (( _, label_, _ ) as option) ->
            ( Dropdown
                { dropdown
                    | selected = Just option
                    , text = label_
                }
            , Cmd.none
            , Selected option
            )

        OnMouseMove option ->
            nothingToDo
                (Dropdown
                    { dropdown
                        | hovered = Just option
                        , navType = Just Mouse
                    }
                )

        OnMouseEnterOption option ->
            nothingToDo
                (Dropdown
                    { dropdown
                        | hovered =
                            case dropdown.navType of
                                Just Keyboard ->
                                    dropdown.hovered

                                Just Mouse ->
                                    Just option

                                Nothing ->
                                    Just option
                    }
                )

        OnMouseEnter ->
            if dropdown.openOnEnter then
                ( Dropdown
                    { dropdown
                        | show = True
                        , matchedOptions = updateMatchedOptions dropdown.filterType dropdown.text dropdown.options
                    }
                , Task.attempt GotFocus <|
                    Dom.focus (dropdown.id ++ "-button")
                , NoOp
                )

            else
                nothingToDo (Dropdown dropdown)

        OnMouseLeave ->
            if dropdown.openOnEnter then
                nothingToDo
                    (Dropdown { dropdown | show = False })

            else
                nothingToDo (Dropdown dropdown)

        OnChange text ->
            ( Dropdown
                { dropdown
                    | text = text
                    , matchedOptions = updateMatchedOptions dropdown.filterType text dropdown.options
                    , hovered = Nothing
                    , selected = Nothing
                    , show = True
                }
            , Cmd.none
            , TextChanged text
            )

        BtnLabelFocus ->
            ( Dropdown
                { dropdown
                    | show = True
                    , matchedOptions = updateMatchedOptions dropdown.filterType dropdown.text dropdown.options
                }
            , Task.attempt GotFocus <|
                Dom.focus (dropdown.id ++ "-button")
            , FocusIn
            )

        GotFocus _ ->
            nothingToDo (Dropdown dropdown)

        BtnClick ->
            nothingToDo
                (Dropdown { dropdown | show = not dropdown.show })

        OnFocus ->
            ( Dropdown
                { dropdown
                    | matchedOptions = updateMatchedOptions dropdown.filterType dropdown.text dropdown.options
                }
            , Process.sleep 20
                |> Task.perform (\_ -> ShowMenu)
            , FocusIn
            )

        ShowMenu ->
            nothingToDo (Dropdown { dropdown | show = True })

        OnLoseFocus ->
            ( Dropdown
                { dropdown
                    | show = False
                    , hovered = Nothing
                }
            , Cmd.none
            , FocusOut
            )

        OnKeyDown code ->
            case code of
                13 ->
                    enter (Dropdown dropdown)

                27 ->
                    escape (Dropdown dropdown)

                38 ->
                    up (Dropdown dropdown)

                40 ->
                    down (Dropdown dropdown)

                _ ->
                    nothingToDo (Dropdown dropdown)

        GetElement keyDirection index result ->
            case result of
                Ok { element } ->
                    ( Dropdown dropdown
                    , Task.attempt (GetViewport keyDirection index element.height) <|
                        Dom.getViewportOf dropdown.id
                    , NoOp
                    )

                Err _ ->
                    nothingToDo (Dropdown dropdown)

        GetViewport keyDirection index optionHeight result ->
            case result of
                Ok { viewport } ->
                    let
                        topBoundary =
                            viewport.y

                        bottomBoundary =
                            topBoundary + viewport.height

                        optionTop =
                            toFloat index * optionHeight

                        optionBottom =
                            optionTop + optionHeight
                    in
                    case keyDirection of
                        Down ->
                            if optionBottom < topBoundary then
                                ( Dropdown dropdown
                                , Dom.setViewportOf dropdown.id 0 optionTop
                                    |> Task.attempt PositionElement
                                , NoOp
                                )

                            else if optionBottom > bottomBoundary then
                                ( Dropdown dropdown
                                , Dom.setViewportOf dropdown.id 0 (optionTop + optionHeight - viewport.height)
                                    |> Task.attempt PositionElement
                                , NoOp
                                )

                            else
                                nothingToDo (Dropdown dropdown)

                        Up ->
                            if optionTop < topBoundary then
                                ( Dropdown dropdown
                                , Dom.setViewportOf dropdown.id 0 optionTop
                                    |> Task.attempt PositionElement
                                , NoOp
                                )

                            else
                                nothingToDo (Dropdown dropdown)

                Err _ ->
                    nothingToDo (Dropdown dropdown)

        PositionElement _ ->
            nothingToDo (Dropdown dropdown)


updateMatchedOptions : FilterType -> String -> List (Option option) -> List (Option option)
updateMatchedOptions filterType_ val options_ =
    let
        setIndex index ( _, label_, option ) =
            ( index, label_, option )

        setIndices : List (Option option) -> List (Option option)
        setIndices =
            List.indexedMap setIndex
    in
    case filterType_ of
        NoFilter ->
            options_

        StartsWith ->
            filterStartsWith val options_
                |> setIndices

        Contains ->
            filterContains val options_
                |> setIndices

        StartsWithThenContains ->
            filterStartsWithThenContains val options_
                |> setIndices


nothingToDo : Dropdown option -> ( Dropdown option, Cmd (Msg option), OutMsg option )
nothingToDo dropdown =
    ( dropdown, Cmd.none, NoOp )



{- Keyboard Controls -}


escape : Dropdown option -> ( Dropdown option, Cmd (Msg option), OutMsg option )
escape (Dropdown dropdown) =
    nothingToDo
        (Dropdown
            { dropdown
                | show = False
                , hovered = Nothing
            }
        )


enter : Dropdown option -> ( Dropdown option, Cmd (Msg option), OutMsg option )
enter (Dropdown dropdown) =
    case ( dropdown.show, dropdown.hovered ) of
        ( True, Just (( _, label_, _ ) as option) ) ->
            ( Dropdown
                { dropdown
                    | selected = dropdown.hovered
                    , text = label_
                    , show = False
                    , hovered = Nothing
                }
            , Cmd.none
            , Selected option
            )

        ( True, Nothing ) ->
            let
                selected_ =
                    List.filter (\( _, label_, _ ) -> label_ == dropdown.text) dropdown.matchedOptions
                        |> List.head
            in
            ( Dropdown
                { dropdown
                    | selected = selected_
                    , show = False
                    , hovered = Nothing
                }
            , Cmd.none
            , case selected_ of
                Just s ->
                    Selected s

                Nothing ->
                    NoOp
            )

        _ ->
            nothingToDo (Dropdown dropdown)


type KeyDirection
    = Down
    | Up


down : Dropdown option -> ( Dropdown option, Cmd (Msg option), OutMsg option )
down (Dropdown dropdown) =
    case dropdown.hovered of
        Nothing ->
            ( Dropdown
                { dropdown
                    | hovered = List.head dropdown.matchedOptions
                    , show = True
                    , navType = Just Keyboard
                }
            , if dropdown.show then
                getElement Down 0 dropdown.id

              else
                Cmd.none
            , NoOp
            )

        Just ( index, _, _ ) ->
            if dropdown.show == True && index < List.length dropdown.matchedOptions - 1 then
                ( Dropdown
                    { dropdown
                        | hovered =
                            List.filter (\( i, _, _ ) -> i == index + 1) dropdown.matchedOptions
                                |> List.head
                        , navType = Just Keyboard
                    }
                , getElement Down (index + 1) dropdown.id
                , NoOp
                )

            else
                nothingToDo
                    (Dropdown
                        { dropdown
                            | show = True
                            , navType = Just Keyboard
                        }
                    )


up : Dropdown option -> ( Dropdown option, Cmd (Msg option), OutMsg option )
up (Dropdown dropdown) =
    case dropdown.hovered of
        Nothing ->
            nothingToDo (Dropdown dropdown)

        Just ( index, _, _ ) ->
            if index > 0 then
                ( Dropdown
                    { dropdown
                        | hovered =
                            List.filter (\( i, _, _ ) -> i == index - 1) dropdown.matchedOptions
                                |> List.head
                        , navType = Just Keyboard
                    }
                , getElement Up (index - 1) dropdown.id
                , NoOp
                )

            else
                nothingToDo (Dropdown dropdown)


getElement : KeyDirection -> Int -> String -> Cmd (Msg option)
getElement keyDirection index id_ =
    Task.attempt (GetElement keyDirection index) <|
        Dom.getElement (toOptionId index id_)


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    El.htmlAttribute <|
        on "keydown" (Json.map tagger keyCode)



{- Filters -}


filterStartsWithThenContains : String -> List (Option option) -> List (Option option)
filterStartsWithThenContains val options_ =
    let
        startsWith =
            filterStartsWith val options_

        contains =
            filterContains val options_
                |> List.filter (\v -> not <| List.member v startsWith)
    in
    List.append startsWith contains


filterStartsWith : String -> List (Option option) -> List (Option option)
filterStartsWith =
    filter String.startsWith


filterContains : String -> List (Option option) -> List (Option option)
filterContains =
    filter String.contains


filter : (String -> String -> Bool) -> String -> List (Option option) -> List (Option option)
filter condFunc val =
    let
        val_ =
            String.toLower val
    in
    List.filter
        (\( _, label_, _ ) ->
            String.toLower label_
                |> condFunc val_
        )



{- Views -}


{-| Render the dropdown.

    import Dropdown

    type alias Model =
        { dropdown : Dropdown String }

    type Msg
        = DropdownMsg Dropdown.Msg

    view : Model -> Element Msg
    view model =
        Dropdown.view DropdownMsg model.dropdown

-}
view : (Msg option -> msg) -> Dropdown option -> Element msg
view toMsg (Dropdown dropdown) =
    let
        menu =
            if dropdown.show then
                menuView (Dropdown dropdown)

            else
                El.none

        attrs id_ =
            List.append
                [ Background.color white
                , Border.color black
                , Border.width 1
                , Border.rounded 5
                , El.htmlAttribute <|
                    Attr.id (dropdown.id ++ "-" ++ id_)
                , El.padding 5
                , Event.onFocus OnFocus
                , Event.onLoseFocus OnLoseFocus
                , Font.color black
                , onKeyDown OnKeyDown
                ]
                dropdown.inputAttributes

        labelPadding =
            El.paddingEach <|
                case dropdown.labelPlacement of
                    Above ->
                        { paddingEach | bottom = dropdown.labelSpacing }

                    Below ->
                        { paddingEach | top = dropdown.labelSpacing }

                    Left ->
                        { paddingEach | right = dropdown.labelSpacing }

                    Right ->
                        { paddingEach | left = dropdown.labelSpacing }
    in
    El.el
        [ case dropdown.menuPlacement of
            Above ->
                El.above menu

            Below ->
                El.below menu

            Left ->
                El.onLeft menu

            Right ->
                El.onRight menu
        , El.width El.fill
        , Event.onMouseEnter OnMouseEnter
        , Event.onMouseLeave OnMouseLeave
        ]
        (case dropdown.inputType of
            TextField ->
                Input.text
                    (attrs "text-field")
                    { text = dropdown.text
                    , onChange = OnChange
                    , placeholder = dropdown.placeholder
                    , label =
                        case dropdown.labelHidden of
                            ( True, text ) ->
                                Input.labelHidden text

                            ( False, _ ) ->
                                case dropdown.labelPlacement of
                                    Above ->
                                        Input.labelAbove
                                            [ El.width El.fill
                                            , labelPadding
                                            ]
                                            dropdown.label

                                    Below ->
                                        Input.labelBelow
                                            [ El.width El.fill
                                            , labelPadding
                                            ]
                                            dropdown.label

                                    Left ->
                                        Input.labelLeft [ labelPadding ] dropdown.label

                                    Right ->
                                        Input.labelRight [ labelPadding ] dropdown.label
                    }

            Button ->
                let
                    button =
                        Input.button
                            (attrs "button")
                            { onPress = Just BtnClick
                            , label =
                                case dropdown.selected of
                                    Nothing ->
                                        dropdown.buttonLabel

                                    Just ( _, label_, _ ) ->
                                        El.el
                                            [ El.centerX ]
                                            (El.text label_)
                            }

                    buttonLabel_ =
                        El.el
                            [ Event.onClick BtnLabelFocus
                            , labelPadding
                            ]
                            dropdown.label

                    column =
                        El.column [ El.width El.fill ]

                    row =
                        El.row []
                in
                case ( dropdown.labelHidden, dropdown.labelPlacement ) of
                    ( ( True, _ ), _ ) ->
                        button

                    ( _, Above ) ->
                        column
                            [ buttonLabel_
                            , button
                            ]

                    ( _, Below ) ->
                        column
                            [ button
                            , buttonLabel_
                            ]

                    ( _, Left ) ->
                        row
                            [ buttonLabel_
                            , button
                            ]

                    ( _, Right ) ->
                        row
                            [ button
                            , buttonLabel_
                            ]
        )
        |> El.map toMsg


menuView : Dropdown option -> Element (Msg option)
menuView (Dropdown dropdown) =
    if dropdown.show then
        El.el
            [ El.width El.fill
            , El.paddingEach <|
                case dropdown.menuPlacement of
                    Above ->
                        { paddingEach | bottom = dropdown.menuSpacing }

                    Below ->
                        { paddingEach | top = dropdown.menuSpacing }

                    Left ->
                        { paddingEach | right = dropdown.menuSpacing }

                    Right ->
                        { paddingEach | left = dropdown.menuSpacing }
            ]
        <|
            El.column
                (List.append
                    [ Background.color white
                    , Border.color black
                    , Border.width 1
                    , Border.rounded 5
                    , El.htmlAttribute <|
                        Attr.id dropdown.id
                    , El.height <|
                        El.maximum dropdown.maxHeight El.shrink
                    , El.scrollbarY
                    , El.width El.fill
                    , Font.color black
                    ]
                    dropdown.menuAttributes
                )
            <|
                List.map (optionView (Dropdown dropdown)) dropdown.matchedOptions

    else
        El.none


optionView : Dropdown option -> Option option -> Element (Msg option)
optionView (Dropdown dropdown) (( index, label_, _ ) as option) =
    El.el
        (List.append
            [ if dropdown.selected == Just option then
                Cursor.default

              else
                Cursor.pointer
            , El.htmlAttribute <|
                Attr.id (toOptionId index dropdown.id)
            , El.width El.fill
            , Event.onMouseDown (OnMouseDown option)
            , Event.onMouseEnter (OnMouseEnterOption option)
            , Event.onMouseMove (OnMouseMove option)
            ]
            (if dropdown.selected == Just option then
                List.append
                    [ Background.color black
                    , Font.color white
                    , El.padding 5
                    ]
                    dropdown.optionSelectedAttributes

             else if dropdown.hovered == Just option then
                List.append
                    [ Background.color grey
                    , El.padding 5
                    ]
                    dropdown.optionHoverAttributes

             else
                List.append
                    [ El.padding 5 ]
                    dropdown.optionAttributes
            )
        )
        (El.text label_)


type alias PaddingEach =
    { left : Int
    , top : Int
    , right : Int
    , bottom : Int
    }


paddingEach : PaddingEach
paddingEach =
    { left = 0
    , top = 0
    , right = 0
    , bottom = 0
    }
