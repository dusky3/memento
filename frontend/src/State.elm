port module State exposing (..)

import Api
import Json.Decode as JD
import Platform.Cmd as Cmd
import RemoteData exposing (..)
import Types exposing (..)


port logStatus : JD.Value -> Cmd msg


initialPage : Page
initialPage =
    1


perPage : PerPage
perPage =
    25


init : ( Model, Cmd Msg )
init =
    ( { filterBy = Nothing
      , entries = Loading
      , moreEntries = NotAsked
      , page = initialPage
      , perPage = perPage
      , query = Nothing
      }
    , Cmd.batch
        [ Api.getEntries perPage initialPage Nothing
        , Api.status
        ]
    )


combineEntries : WebData (List Entry) -> WebData (List Entry) -> WebData (List Entry)
combineEntries currentEntries moreEntries =
    case moreEntries of
        Success entries ->
            RemoteData.map (\current -> current ++ entries) currentEntries

        otherwise ->
            currentEntries


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        EntriesResponse resp ->
            case model.moreEntries of
                Loading ->
                    { model | moreEntries = resp } ! []

                otherwise ->
                    { model | entries = resp } ! []

        RefreshResponse resp ->
            case resp of
                Success Done ->
                    update ClearFilter model

                otherwise ->
                    update ClearFilter model

        FilterBy source ->
            ( { model
                | entries = Loading
                , filterBy = Just source
                , page = initialPage
              }
            , Api.getEntries model.perPage initialPage (Just source)
            )

        ClearFilter ->
            ( { model
                | entries = Loading
                , filterBy = Nothing
                , page = initialPage
              }
            , Api.getEntries model.perPage initialPage Nothing
            )

        LoadMore ->
            let
                newModel =
                    { model
                        | entries = combineEntries model.entries model.moreEntries
                        , moreEntries = Loading
                        , page = model.page + 1
                    }
            in
            case newModel.query of
                Nothing ->
                    ( newModel
                    , Api.getEntries model.perPage (model.page + 1) model.filterBy
                    )

                Just query ->
                    ( newModel
                    , Api.searchEntries query newModel.perPage newModel.page
                    )

        Refresh ->
            ( { model | entries = Loading }
            , Api.refresh
            )

        StatusResponse statusResponse ->
            case statusResponse of
                Success status ->
                    ( model, logStatus status )

                otherwise ->
                    model ! []

        Search query ->
            let
                newModel =
                    { model
                        | query = Just query
                        , page = initialPage
                        , filterBy = Nothing
                        , entries = Loading
                        , moreEntries = NotAsked
                    }
            in
            if String.length query <= 2 then
                ( newModel
                , Api.getEntries newModel.perPage newModel.page newModel.filterBy
                )
            else
                ( newModel
                , Api.searchEntries query newModel.perPage newModel.page
                )
