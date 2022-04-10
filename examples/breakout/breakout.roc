app "breakout"
    packages { pf: "platform" }
    imports []# [ pf.Action.{ Action }, pf.Elem.{ button, text, row, col } ]
    provides [ program ] to pf

program = { render }

render = \state ->
    numRows = 4
    numCols = 8
    numBlocks = numRows * numCols

    blocks = List.map (List.range 0 numBlocks) \index ->
        col =
            Num.rem index numCols
                |> Result.withDefault 0
                |> Num.toF32

        row =
            index // numCols
                |> Result.withDefault 0
                |> Num.toF32

        red = (col / Num.toF32 numCols) |> Result.withDefault 0
        green = ((row / Num.toF32 numRows) |> Result.withDefault 0)
        blue = (Num.toF32 index / Num.toF32 numBlocks) |> Result.withDefault 0

        color = { r: red * 0.8, g: 0.2 + green * 0.6, b: 0.2 + blue * 0.8, a: 1 }

        { row, col, color }

    blockWidth = state.width / numCols |> Result.withDefault 0
    blockHeight = 80

    List.map blocks \{ row, col, color } ->
        left = Num.toF32 col * blockWidth
        top = Num.toF32 (row * blockHeight)

        Rect { left, top, width: blockWidth, height: blockHeight, color }
