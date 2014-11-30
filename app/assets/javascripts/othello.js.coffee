# Othello {{{

class Othello
  constructor: ->
    @judge = new Judge('normal')   # TODO:htmlの要素から選択できるように
    @outputer = new OutputText
    @board = new Board(@judge.rule.b_height, @judge.rule.b_width)
    @board.init_board
    @player = []
    for k in [0..@judge.rule.player_num]
      @player[k] = new Player
  run: ->
    @outputer.show_board(@board)
# }}}

# Input {{{
class InputType

class Keyboard extends InputType
  constructor: ->

class Mouse extends InputType
  constructor: ->
# }}}

# Output {{{
class OutputType
  @show_board: (board) ->
  @show_piece: (piece) ->

class OutputImage extends OutputType
  ## field
  # image_size
  @width
  @height
  constructor: ->

class OutputText extends OutputType
  constructor: ->

  show_piece: (piece) ->
    # console.log('・') unless piece?
    white = new Piece(0)
    black = new Piece(1)
    console.log('白') if piece == white
    console.log('黒') if piece == black

  show_board: (board) ->
    for x in [0..8]
      for y in [0..8]
        @show_piece(board.cells.piace)

# }}}

# Player {{{
class Player
  ## field
  @order
  @Piece
  constructor: ->

  ## method
  @dicide_hand: ->

class User extends Player
  ## method
  constructor: (piece_num, order) ->
    null

  @dicide_hand: ->
    [x, y]

class Computer extends Player
  constructor: () ->
    null
# }}}

# Board {{{
class Board
  constructor: (height, width) ->
    _height = height
    _width = width
    @cells = [0..height][0..width]
    for line in @cells
      for cell in line
        @cells[line][cell] = new Cell

  init_board: ->
    x = _height/2 - 1
    y = _width/2
    @cells[x][x].piace = @cells[y][y] = new Piece(0)
    @cells[x][y].piace = @cells[y][x] = new Piece(1)

class Cell
  constructor: ->
    @piece = null

class Piece
  constructor: (order) ->
    @color = Color.colors[order]

class Color
  @colors = ['black', 'white', 'blue', 'red']
# }}}

# Judge {{{
class Judge
  constructor: (type)->
    if type == 'normal'
      @rule = new NormalRule

class Rule
  @b_width
  @b_height
  @player_num
  @piece_num

class NormalRule extends Rule
  constructor: ->
    @b_width = @b_height = 8
    @player_num = 2
    @piece_num = @b_width * @b_height
# }}}

@othello = new Othello
