module Dropdown exposing
    ( Dropdown, init, id
    , InputType(..), inputType
    , optionsBy, options, stringOptions, intOptions, floatOptions, Option(..), elementOptions, reset
    , label, labelHidden, buttonLabel
    , placeholder
    , defaultClearButton, clearButton
    , Placement(..)
    , labelPlacement, labelSpacing
    , menuPlacement, menuSpacing
    , maxHeight, labelAttributes, inputAttributes, menuAttributes, optionAttributes, optionHoverAttributes, optionSelectedAttributes
    , FilterType(..), filterType
    , setSelected, removeSelected, removeOption
    , setSelectedLabel
    , openOnMouseEnter, open, close
    , selected, selectedOption, selectedLabel, list, listOptions, listLabels, text, isOpen, getId
    , OutMsg(..), Msg, update
    , subscriptions
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
function or section has a warning documenting this restriction where it is
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

@docs optionsBy, options, stringOptions, intOptions, floatOptions, Option, elementOptions, reset


### Label

@docs label, labelHidden, buttonLabel


### Placeholder

@docs placeholder


### Clear Button

This can be added to a `TextField` `InputType` in order to clear the text field.

@docs defaultClearButton, clearButton


### Positioning

@docs Placement

@docs labelPlacement, labelSpacing

@docs menuPlacement, menuSpacing


### Size & Style

@docs maxHeight, labelAttributes, inputAttributes, menuAttributes, optionAttributes, optionHoverAttributes, optionSelectedAttributes


### Filtering

Filtering is currently case insensitive.

@docs FilterType, filterType


### Selected Option

@docs setSelected, removeSelected, removeOption


### Selected Label

@docs setSelectedLabel


### Controls

@docs openOnMouseEnter, open, close


## Query

@docs selected, selectedOption, selectedLabel, list, listOptions, listLabels, text, isOpen, getId


## Update

@docs OutMsg, Msg, update


## Subscriptions

@docs subscriptions


## View

@docs view

-}

import Browser.Dom as Dom
import Browser.Events exposing (onResize)
import Element as El exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Cursor as Cursor
import Element.Events as Event
import Element.Font as Font
import Element.Input as Input exposing (Placeholder)
import Html.Attributes as Attr
import Html.Events exposing (keyCode, on)
import Html.Events.Extra.Touch as Touch
import Json.Decode as Json
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

-}
type Dropdown option
    = Dropdown
        { id : String
        , inputType : InputType
        , options : List (Option option)
        , optionsCache : List (Option option)
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
        , labelAttributes : List (Attribute (Msg option))
        , inputAttributes : List (Attribute (Msg option))
        , menuAttributes : List (Attribute (Msg option))
        , optionAttributes : List (Attribute (Msg option))
        , optionHoverAttributes : List (Attribute (Msg option))
        , optionSelectedAttributes : List (Attribute (Msg option))
        , text : String
        , clearBtn : Maybe (Element (Msg option))
        , selected : Maybe (Option option)
        , hovered : Maybe (Option option)
        , gotFocus : Bool
        , show : Bool
        , openOnEnter : Bool
        , matchedOptions : List (Option option)
        , navType : Maybe NavType
        , menuTouchActive : Bool
        }


{-| -}
type Option option
    = Option ( Int, String, option )
    | Element ( Int, Element (Msg option), option )


type NavType
    = Keyboard
    | Mouse
    | Touch


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
        , optionsCache = []
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
        , labelAttributes = []
        , inputAttributes = []
        , menuAttributes = []
        , optionAttributes = []
        , optionHoverAttributes = []
        , optionSelectedAttributes = []
        , text = ""
        , clearBtn = Nothing
        , selected = Nothing
        , hovered = Nothing
        , gotFocus = False
        , show = False
        , openOnEnter = False
        , matchedOptions = []
        , navType = Nothing
        , menuTouchActive = False
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
    let
        options__ =
            List.indexedMap (\index option -> Option ( index, accessorFunc option, option )) options_
    in
    Dropdown
        { dropdown
            | options = options__
            , optionsCache = options__
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
    let
        options__ =
            List.indexedMap (\index ( label_, option ) -> Option ( index, label_, option )) options_
    in
    Dropdown
        { dropdown
            | options = options__
            , optionsCache = options__
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


{-| -}
elementOptions : List ( Element (Msg option), option ) -> Dropdown option -> Dropdown option
elementOptions options_ (Dropdown dropdown) =
    let
        options__ =
            List.indexedMap (\index ( element, option ) -> Element ( index, element, option )) options_
    in
    Dropdown
        { dropdown
            | options = options__
            , optionsCache = options__
        }


{-| Reset the dropdown.

The selected option will be set to `Nothing`.
The list of options will be reset to the last full list of options supplied
if any options have been programmatically removed.

-}
reset : Dropdown option -> Dropdown option
reset (Dropdown dropdown) =
    Dropdown
        { dropdown
            | selected = Nothing
            , text = ""
            , options = dropdown.optionsCache
        }


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


{-| Provide the
[Placeholder](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/Element-Input#Placeholder)
for the text field if [TextField](#InputType) is the [InputType](#InputType).

The default is `Nothing`.

-}
clearButton : Maybe (Element (Msg option)) -> Dropdown option -> Dropdown option
clearButton btnElement (Dropdown dropdown) =
    Dropdown { dropdown | clearBtn = btnElement }


{-| A default [clearButton](#clearButton).
-}
defaultClearButton : Maybe (Element (Msg option))
defaultClearButton =
    Just <|
        El.text <|
            String.fromChar '✘'


{-| The max height for the dropdown, the default is 150.

(Vertical scrolling kicks in automatically.)

-}
maxHeight : Int -> Dropdown option -> Dropdown option
maxHeight height (Dropdown dropdown) =
    Dropdown { dropdown | maxHeight = height }


{-| The
[Attributes](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/Element#Attribute)
to set on the label.
-}
labelAttributes : List (Attribute (Msg option)) -> Dropdown option -> Dropdown option
labelAttributes attrs (Dropdown dropdown) =
    Dropdown { dropdown | labelAttributes = attrs }


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
                    List.filter
                        (\optionType ->
                            case optionType of
                                Option ( _, _, option_ ) ->
                                    option_ == option

                                Element ( _, _, option_ ) ->
                                    option_ == option
                        )
                        dropdown.options
                        |> List.head
            in
            Dropdown
                { dropdown
                    | selected = maybeSelected
                }


{-| Set the selected label - it must exist in the list of
[options originally provided](#setting-options).

**Warning**

This function changes the internal state, and so needs to be used where the
state change can be captured. This is likely to be your `update` function.

If you use this in your `view` code it will have no effect.

-}
setSelectedLabel : Maybe String -> Dropdown option -> Dropdown option
setSelectedLabel maybeLabel (Dropdown dropdown) =
    case maybeLabel of
        Nothing ->
            Dropdown
                { dropdown
                    | selected = Nothing
                    , text = ""
                }

        Just label_ ->
            let
                maybeSelected =
                    List.filter
                        (\optionType ->
                            case optionType of
                                Option ( _, l, _ ) ->
                                    l == label_

                                _ ->
                                    False
                        )
                        dropdown.options
                        |> List.head
            in
            Dropdown
                { dropdown
                    | selected = maybeSelected
                    , text =
                        case maybeSelected of
                            Just (Option ( _, l, _ )) ->
                                l

                            Just (Element _) ->
                                ""

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

    awayTeamDropdown =
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

        Just optionType1 ->
            Dropdown
                { fromDropdown
                    | options =
                        List.filter
                            (\optionType2 ->
                                case ( optionType1, optionType2 ) of
                                    ( Option ( _, _, option1 ), Option ( _, _, option2 ) ) ->
                                        option1 /= option2

                                    ( Element ( _, _, option1 ), Element ( _, _, option2 ) ) ->
                                        option1 /= option2

                                    ( Option ( _, _, option1 ), Element ( _, _, option2 ) ) ->
                                        option1 /= option2

                                    ( Element ( _, _, option1 ), Option ( _, _, option2 ) ) ->
                                        option1 /= option2
                            )
                            fromDropdown.options
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
                List.filter
                    (\optionType ->
                        case optionType of
                            Option ( _, _, option_ ) ->
                                option /= option_

                            Element ( _, _, option_ ) ->
                                option /= option_
                    )
                    dropdown.options
            , matchedOptions =
                List.filter
                    (\optionType ->
                        case optionType of
                            Option ( _, _, option_ ) ->
                                option /= option_

                            Element ( _, _, option_ ) ->
                                option /= option_
                    )
                    dropdown.matchedOptions
        }



{- Controls -}


{-| Choose whether the menu opens when the mouse enters.

If this is set to `True` the menu will also close automatically when the mouse
leaves.

The default is `False`.

**Warning**

This function changes the internal state, and so needs to be used where the
state change can be captured. This is likely to be your `update` function.

If you use this in your `view` code it will have no effect.

-}
openOnMouseEnter : Bool -> Dropdown option -> Dropdown option
openOnMouseEnter state (Dropdown dropdown) =
    Dropdown { dropdown | openOnEnter = state }


{-| -}
open : Dropdown option -> Dropdown option
open (Dropdown dropdown) =
    Dropdown { dropdown | show = True }


{-| -}
close : Dropdown option -> Dropdown option
close (Dropdown dropdown) =
    Dropdown { dropdown | show = False }



{- Queries -}


{-| Determine if an option has been selected by the user.

If a `Just` is returned, it consists of the following:

  - `Int`: The index of the selected option.
  - `String`: The label of the selected option.
  - `option`: The option value itself.

-}
selected : Dropdown option -> Maybe (Option option)
selected (Dropdown dropdown) =
    dropdown.selected


{-| Maybe retrieve the selected option.
-}
selectedOption : Dropdown option -> Maybe option
selectedOption =
    selected
        >> Maybe.map
            (\optionType ->
                case optionType of
                    Option ( _, _, option ) ->
                        option

                    Element ( _, _, option ) ->
                        option
            )


{-| Maybe retrieve the label for the selected option.
-}
selectedLabel : Dropdown option -> Maybe String
selectedLabel =
    selected
        >> Maybe.map
            (\optionType ->
                case optionType of
                    Option ( _, label_, _ ) ->
                        label_

                    Element _ ->
                        ""
            )


{-| List all the `option` information. The tuples returned represent:

  - Int - the index of the `option`
  - String - the label for the `option`
  - option - the `option` itself

-}
list : Dropdown option -> List (Option option)
list (Dropdown dropdown) =
    dropdown.options


{-| List all the `option`s.
-}
listOptions : Dropdown option -> List option
listOptions (Dropdown dropdown) =
    List.map
        (\optionType ->
            case optionType of
                Option ( _, _, option ) ->
                    option

                Element ( _, _, option ) ->
                    option
        )
        dropdown.options


{-| List all the labels for each option.
-}
listLabels : Dropdown option -> List String
listLabels (Dropdown dropdown) =
    List.map
        (\optionType ->
            case optionType of
                Option ( _, label_, _ ) ->
                    label_

                Element _ ->
                    ""
        )
        dropdown.options


{-| Get the text entered in the [TextField](#InputType).
-}
text : Dropdown option -> String
text (Dropdown dropdown) =
    dropdown.text


{-| Determine if the dropdown is open or not.
-}
isOpen : Dropdown option -> Bool
isOpen (Dropdown dropdown) =
    dropdown.show


{-| Get the `id` of the dropdown.
-}
getId : Dropdown option -> String
getId (Dropdown dropdown) =
    dropdown.id


toIndex : Option option -> Int
toIndex option =
    case option of
        Option ( index, _, _ ) ->
            index

        Element ( index, _, _ ) ->
            index



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
    | Selected (Option option)
    | TextChanged String
    | FocusIn
    | FocusOut
    | Opened
    | Closed
    | Cleared


{-| This is an opaque type, pattern match on [OutMsg](#OutMsg).
-}
type Msg option
    = OnResize Int Int
    | OnTouchButtonStart
    | OnTouchButtonEnd
    | OnTouchMenuStart
    | OnTouchMenuEnd
    | OnMouseEnter
    | OnMouseDown
    | OnMouseLeave
    | OnMouseDownOption (Option option)
    | OnMouseMoveOption (Option option)
    | OnMouseEnterOption (Option option)
    | OnChange String
    | BtnLabelFocus
    | GotClearText
    | GotFocus (Result Dom.Error ())
    | BtnClick Bool
    | OnFocus
    | ShowMenu
    | HideMenu
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
        OnResize _ _ ->
            ( Dropdown dropdown
            , Task.attempt GotFocus <|
                Dom.focus <|
                    if dropdown.inputType == Button then
                        dropdown.id ++ "-button"

                    else
                        dropdown.id ++ "-text-field"
            , NoOp
            )

        OnTouchButtonStart ->
            nothingToDo (Dropdown dropdown)

        OnTouchButtonEnd ->
            if not dropdown.menuTouchActive then
                if dropdown.show then
                    ( Dropdown { dropdown | show = False }
                    , Cmd.none
                    , Closed
                    )

                else
                    ( Dropdown
                        { dropdown
                            | navType = Just Touch
                            , gotFocus = True
                            , matchedOptions = updateMatchedOptions dropdown.filterType dropdown.text dropdown.options
                        }
                    , Task.attempt GotFocus <|
                        Dom.focus (dropdown.id ++ "-button")
                    , NoOp
                    )

            else
                nothingToDo (Dropdown dropdown)

        OnTouchMenuStart ->
            nothingToDo (Dropdown { dropdown | menuTouchActive = True })

        OnTouchMenuEnd ->
            nothingToDo (Dropdown { dropdown | menuTouchActive = False })

        OnMouseEnter ->
            if dropdown.openOnEnter then
                ( Dropdown
                    { dropdown
                        | matchedOptions = updateMatchedOptions dropdown.filterType dropdown.text dropdown.options
                    }
                , Cmd.batch
                    [ perform ShowMenu
                    , Task.attempt GotFocus <|
                        Dom.focus
                            (dropdown.id
                                ++ (case dropdown.inputType of
                                        Button ->
                                            "-button"

                                        TextField ->
                                            "-text-field"
                                   )
                            )
                    ]
                , NoOp
                )

            else
                nothingToDo (Dropdown dropdown)

        OnMouseDown ->
            nothingToDo (Dropdown { dropdown | navType = Just Mouse })

        OnMouseLeave ->
            if dropdown.openOnEnter then
                ( Dropdown dropdown
                , perform HideMenu
                , NoOp
                )

            else
                nothingToDo (Dropdown dropdown)

        OnMouseDownOption ((Option ( _, label_, _ )) as option) ->
            ( Dropdown
                { dropdown
                    | selected = Just option
                    , text = label_
                }
            , Cmd.none
            , Selected option
            )

        OnMouseDownOption ((Element _) as option) ->
            ( Dropdown
                { dropdown
                    | selected = Just option
                }
            , Cmd.none
            , Selected option
            )

        OnMouseMoveOption option ->
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
                        | hovered = Just option
                    }
                )

        OnChange text_ ->
            ( Dropdown
                { dropdown
                    | text = text_
                    , matchedOptions = updateMatchedOptions dropdown.filterType text_ dropdown.options
                    , hovered = Nothing
                    , selected = Nothing
                }
            , perform ShowMenu
            , TextChanged text_
            )

        BtnLabelFocus ->
            ( Dropdown
                { dropdown
                    | matchedOptions = updateMatchedOptions dropdown.filterType dropdown.text dropdown.options
                }
            , Task.attempt GotFocus <|
                Dom.focus (dropdown.id ++ "-button")
            , NoOp
            )

        GotClearText ->
            ( Dropdown
                { dropdown
                    | selected = Nothing
                    , text = ""
                }
            , Cmd.none
            , Cleared
            )

        GotFocus _ ->
            ( Dropdown dropdown
            , perform ShowMenu
            , FocusIn
            )

        BtnClick show ->
            if dropdown.openOnEnter then
                nothingToDo (Dropdown dropdown)

            else if dropdown.navType == Just Mouse then
                ( Dropdown { dropdown | show = show }
                , Cmd.none
                , if show then
                    Opened

                  else
                    Closed
                )

            else
                nothingToDo (Dropdown dropdown)

        OnFocus ->
            ( Dropdown
                { dropdown
                    | matchedOptions = updateMatchedOptions dropdown.filterType dropdown.text dropdown.options
                    , gotFocus = True
                }
            , if dropdown.navType /= Just Mouse then
                perform ShowMenu

              else
                Cmd.none
            , FocusIn
            )

        OnLoseFocus ->
            ( Dropdown
                { dropdown
                    | hovered = Nothing
                    , gotFocus = False
                    , navType = Nothing
                }
            , perform HideMenu
            , FocusOut
            )

        ShowMenu ->
            ( Dropdown { dropdown | show = True }
            , Cmd.none
            , Opened
            )

        HideMenu ->
            ( Dropdown { dropdown | show = False }
            , Cmd.none
            , Closed
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
                        Dom.getViewportOf (dropdown.id ++ "-menu")
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
                                , Dom.setViewportOf (dropdown.id ++ "-menu") 0 optionTop
                                    |> Task.attempt PositionElement
                                , NoOp
                                )

                            else if optionBottom > bottomBoundary then
                                ( Dropdown dropdown
                                , Dom.setViewportOf (dropdown.id ++ "-menu") 0 (optionTop + optionHeight - viewport.height)
                                    |> Task.attempt PositionElement
                                , NoOp
                                )

                            else
                                nothingToDo (Dropdown dropdown)

                        Up ->
                            if optionTop < topBoundary then
                                ( Dropdown dropdown
                                , Dom.setViewportOf (dropdown.id ++ "-menu") 0 optionTop
                                    |> Task.attempt PositionElement
                                , NoOp
                                )

                            else
                                nothingToDo (Dropdown dropdown)

                Err _ ->
                    nothingToDo (Dropdown dropdown)

        PositionElement _ ->
            nothingToDo (Dropdown dropdown)


perform : Msg option -> Cmd (Msg option)
perform msg =
    Task.perform (\_ -> msg) <|
        Task.succeed ()


updateMatchedOptions : FilterType -> String -> List (Option option) -> List (Option option)
updateMatchedOptions filterType_ val options_ =
    let
        setIndex index optionType =
            case optionType of
                Option ( _, label_, option ) ->
                    Option ( index, label_, option )

                Element ( _, el, option ) ->
                    Element ( index, el, option )

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



{- Subscriptions -}


{-| Subscribe to the browser `onResize` event.

When the orientation changes on some mobile devices the dropdown can lose
focus, resulting in it failing to close if the user taps outside the
dropdown.

Subscribing to this `subscription` results in the dropdown regaining focus
when the orientation changes so that the user experience doesn't change.

This subscription is only active when the dropdown is open.

-}
subscriptions : Dropdown option -> Sub (Msg option)
subscriptions (Dropdown dropdown) =
    if dropdown.show then
        onResize OnResize

    else
        Sub.none



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
        ( True, Just ((Option ( _, label_, _ )) as option) ) ->
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
                    List.filter
                        (\optionType ->
                            case optionType of
                                Option ( _, label_, _ ) ->
                                    label_ == dropdown.text

                                Element _ ->
                                    False
                        )
                        dropdown.matchedOptions
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

        Just optionType ->
            let
                index =
                    toIndex optionType
            in
            if dropdown.show == True && index < List.length dropdown.matchedOptions - 1 then
                ( Dropdown
                    { dropdown
                        | hovered =
                            List.filter
                                (\optionType_ ->
                                    case optionType_ of
                                        Option ( i, _, _ ) ->
                                            i == index + 1

                                        Element ( i, _, _ ) ->
                                            i == index + 1
                                )
                                dropdown.matchedOptions
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

        Just optionType ->
            let
                index =
                    toIndex optionType
            in
            if index > 0 then
                ( Dropdown
                    { dropdown
                        | hovered =
                            List.filter
                                (\optionType_ ->
                                    case optionType_ of
                                        Option ( i, _, _ ) ->
                                            i == index - 1

                                        Element ( i, _, _ ) ->
                                            i == index
                                )
                                dropdown.matchedOptions
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
        (\optionType ->
            case optionType of
                Option ( _, label_, _ ) ->
                    String.toLower label_
                        |> condFunc val_

                Element _ ->
                    False
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
            if dropdown.show && List.length dropdown.matchedOptions > 0 then
                menuView (Dropdown dropdown)

            else
                El.none

        attrs =
            [ Background.color white
            , Border.color black
            , Border.width 1
            , Border.rounded 5
            , El.padding 5
            , Event.onFocus OnFocus
            , Event.onLoseFocus OnLoseFocus
            , Font.color black
            , onKeyDown OnKeyDown
            ]
                ++ (case dropdown.inputType of
                        TextField ->
                            [ El.htmlAttribute <|
                                Attr.id (dropdown.id ++ "-textfield")
                            , El.inFront <|
                                case ( dropdown.text, dropdown.clearBtn ) of
                                    ( "", _ ) ->
                                        El.none

                                    ( _, Nothing ) ->
                                        El.none

                                    ( _, Just clearBtn ) ->
                                        El.el
                                            [ Cursor.pointer
                                            , El.alignRight
                                            , El.alignBottom
                                            , El.paddingXY 5 0
                                            , Event.onClick GotClearText
                                            ]
                                        <|
                                            clearBtn
                            ]

                        Button ->
                            [ El.htmlAttribute <|
                                Attr.id (dropdown.id ++ "-button")
                            ]
                   )
                ++ dropdown.inputAttributes

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
        , El.htmlAttribute <|
            Attr.attribute "data-cy" dropdown.id
        , El.htmlAttribute <|
            Attr.id dropdown.id
        , El.width El.fill
        , Event.onMouseEnter OnMouseEnter
        , Event.onMouseLeave OnMouseLeave
        ]
        (case dropdown.inputType of
            TextField ->
                Input.text
                    attrs
                    { text = dropdown.text
                    , onChange = OnChange
                    , placeholder = dropdown.placeholder
                    , label =
                        case dropdown.labelHidden of
                            ( True, text_ ) ->
                                Input.labelHidden text_

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
                            ([ Event.onMouseDown OnMouseDown
                             , El.htmlAttribute <|
                                Touch.onStart (\_ -> OnTouchButtonStart)
                             , El.htmlAttribute <|
                                Touch.onEnd (\_ -> OnTouchButtonEnd)
                             ]
                                ++ attrs
                            )
                            { onPress =
                                if dropdown.gotFocus then
                                    Just (BtnClick (not dropdown.show))

                                else
                                    Nothing
                            , label =
                                case dropdown.selected of
                                    Nothing ->
                                        dropdown.buttonLabel

                                    Just (Option ( _, label_, _ )) ->
                                        El.el
                                            [ El.centerX ]
                                            (El.text label_)

                                    Just (Element ( _, element, _ )) ->
                                        element
                            }

                    buttonLabel_ =
                        El.el
                            ([ El.width El.fill
                             , Event.onClick BtnLabelFocus
                             , labelPadding
                             ]
                                ++ dropdown.labelAttributes
                            )
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
                    , El.height <|
                        El.maximum dropdown.maxHeight El.shrink
                    , El.htmlAttribute <|
                        Attr.id (dropdown.id ++ "-menu")
                    , El.htmlAttribute <|
                        Touch.onWithOptions "touchstart" { stopPropagation = True, preventDefault = False } <|
                            \_ -> OnTouchMenuStart
                    , El.htmlAttribute <|
                        Touch.onWithOptions "touchend" { stopPropagation = True, preventDefault = False } <|
                            \_ -> OnTouchMenuEnd
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
optionView (Dropdown dropdown) option =
    let
        optionsMatch maybeOption =
            case ( maybeOption, option ) of
                ( Just (Option ( _, _, option1 )), Option ( _, _, option2 ) ) ->
                    option1 == option2

                ( Just (Element ( _, _, option1 )), Element ( _, _, option2 ) ) ->
                    option1 == option2

                ( Just (Option ( _, _, option1 )), Element ( _, _, option2 ) ) ->
                    option1 == option2

                ( Just (Element ( _, _, option1 )), Option ( _, _, option2 ) ) ->
                    option1 == option2

                ( Nothing, _ ) ->
                    False
    in
    El.el
        (List.append
            [ if optionsMatch dropdown.selected then
                Cursor.default

              else
                Cursor.pointer
            , El.htmlAttribute <|
                Attr.id (toOptionId (toIndex option) dropdown.id)
            , El.width El.fill
            , Event.onMouseDown (OnMouseDownOption option)
            , Event.onMouseEnter (OnMouseEnterOption option)
            , Event.onMouseMove (OnMouseMoveOption option)
            ]
            (if optionsMatch dropdown.selected then
                List.append
                    [ Background.color black
                    , Font.color white
                    , El.padding 5
                    ]
                    dropdown.optionSelectedAttributes

             else if optionsMatch dropdown.hovered then
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
        (case option of
            Option ( _, label_, _ ) ->
                El.text label_

            Element ( _, element, _ ) ->
                element
        )


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
