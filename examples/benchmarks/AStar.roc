interface AStar exposes [ findPath, Model, initialModel ] imports [Quicksort]

findPath = \costFn, moveFn, start, end -> 
    astar costFn moveFn end (initialModel start)

Model position :
    {
        evaluated : Set position,
        openSet : Set position,
        costs : Dict position F64,
        cameFrom : Dict position position
    }

initialModel : position -> Model position
initialModel = \start ->
    {
        evaluated : Set.empty, 
        openSet : Set.singleton start,
        costs : Dict.singleton start 0, 
        cameFrom : Dict.empty
    }


filterMap : List a, (a -> Result b *) -> List b
filterMap = \list, toResult ->
    List.walk list (\element, accum ->
        when toResult element is
            Ok value ->
                List.append accum value

            Err _ ->
                accum
        )
        []

cheapestOpen : (position -> F64), Model position -> Result position {}
cheapestOpen = \costFn, model ->
    model.openSet
        |> Set.toList
        |> filterMap (\position ->
            when Dict.get model.costs position is
                Err _ ->
                    Err {}

                Ok cost ->
                    Ok { cost: cost + costFn position, position }
                    )
        |> Quicksort.sortBy .cost
        |> List.first
        |> Result.map .position
        |> Result.mapErr (\_ -> {})


reconstructPath : Dict position position, position -> List position
reconstructPath = \cameFrom, goal ->
    when Dict.get cameFrom goal is
        Err _ ->
            []

        Ok next ->
            List.append (reconstructPath cameFrom next) goal

updateCost : position, position, Model position -> Model position
updateCost = \current, neighbor, model ->
    when Dict.get model.costs neighbor is
        Err _ ->
            newCameFrom =
                Dict.insert model.cameFrom neighbor current

            newCosts =
                Dict.insert model.costs neighbor distanceTo

            distanceTo =
                reconstructPath newCameFrom neighbor
                    |> List.len
                    |> Num.toFloat

            { model & 
                costs: newCosts,
                cameFrom: newCameFrom
            }

        Ok previousDistance ->

            newCameFrom =
                Dict.insert model.cameFrom neighbor current

            newCosts =
                Dict.insert model.costs neighbor distanceTo

            distanceTo =
                reconstructPath newCameFrom neighbor
                    |> List.len
                    |> Num.toFloat

            newModel =
                { model & 
                    costs: newCosts,
                    cameFrom: newCameFrom
                }


            if distanceTo < previousDistance then
                newModel

            else
                model

astar : (position, position -> F64), (position -> Set position), position, Model position -> Result (List position) {}
astar = \costFn, moveFn, goal, model ->
    when cheapestOpen (\source -> costFn source goal) model is
        Err {} ->
            Err {}

        Ok current ->
            if current == goal then
                Ok (reconstructPath model.cameFrom goal)

            else
                modelPopped =
                    { model &
                        openSet: Set.remove model.openSet current,
                        evaluated: Set.insert model.evaluated current,
                    }

                neighbors =
                    moveFn current

                newNeighbors =
                    Set.difference neighbors modelPopped.evaluated

                modelWithNeighbors =
                    { modelPopped &
                        openSet: Set.union modelPopped.openSet newNeighbors
                    }

                modelWithCosts =
                    Set.walk newNeighbors (\n, m -> updateCost current n m) modelWithNeighbors

                astar costFn moveFn goal modelWithCosts
