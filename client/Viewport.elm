module Viewport exposing (..)

-- dark
import Defaults
import Types exposing (..)

addPos: Pos -> Pos -> Pos
addPos a b = { x = a.x + b.x, y = a.y + b.y }

subPos: Pos -> Pos -> Pos
subPos a b = { x = a.x - b.x, y = a.y - b.y }

pagePos : Page -> Pos
pagePos page =
  case page of
    Toplevels pos -> pos
    Fn _ pos -> pos

toAbsolute : Model -> VPos -> Pos
toAbsolute m pos =
  let topleft =
        case m.currentPage of
          Toplevels _ -> m.canvas.offset
          Fn _ _ -> m.canvas.fnOffset
  in
  addPos {x = pos.vx, y = pos.vy} topleft

toCenteredOn : Pos -> Pos
toCenteredOn pos =
  subPos pos Defaults.centerPos

toCenter : Pos -> Pos
toCenter pos =
  addPos pos Defaults.centerPos

moveCanvasBy : Model -> Int -> Int -> Modification
moveCanvasBy m x y =
  let c = m.canvas
      offset =
        case m.currentPage of
          Toplevels _ -> c.offset
          Fn _ _ -> c.fnOffset
      pos = addPos offset { x=x, y=y }
  in MoveCanvasTo c m.currentPage pos

pageUp : Model -> Modification
pageUp m =
  moveCanvasBy m 0 (-1 * Defaults.pageHeight)

pageDown : Model -> Modification
pageDown m =
  moveCanvasBy m 0 (Defaults.pageHeight)

pageLeft : Model -> Modification
pageLeft m =
  moveCanvasBy m (-1 * Defaults.pageWidth) 0

pageRight : Model -> Modification
pageRight m =
  moveCanvasBy m Defaults.pageWidth 0

moveUp : Model -> Modification
moveUp m =
  moveCanvasBy m 0 (-1*Defaults.moveSize)

moveDown : Model -> Modification
moveDown m =
  moveCanvasBy m 0 Defaults.moveSize

moveLeft : Model -> Modification
moveLeft m =
  moveCanvasBy m (-1*Defaults.moveSize) 0

moveRight : Model -> Modification
moveRight m =
  moveCanvasBy m Defaults.moveSize 0

moveToOrigin : Model -> Modification
moveToOrigin m =
  MoveCanvasTo m.canvas m.currentPage Defaults.origin


