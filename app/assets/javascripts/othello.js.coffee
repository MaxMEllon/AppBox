# Othello {{{

class Othello
  constructor: ->
    @judge = new Judge('normal')   # TODO:htmlの要素から選択できるように
    # @outputer = new Html
    @outputer = new Console
    @board = new Board(@judge.rule.b_height, @judge.rule.b_width)
    @player = []
    for k in [0..@judge.rule.player_num]
      @player[k] = new Player
  run: ->
    @outputer.show_board(@board)
# }}}

# Input {{{
class InputInterface

class Keyboard extends InputInterface
  constructor: ->

class Mouse extends InputInterface
  constructor: ->
# }}}

# Output {{{
class OutputInterface
  show_board: (board) ->
    height = board.cells.length
    width =  board.cells[0].length
    for x in [0...height]
      for y in [0...width]
        @show_piece(board.cells[x][y].piece)

  show_piece: (piece) ->

  _get_piece_type: (piece) ->
    color = '・' if piece.color == new Piece(-1).color
    color = '白' if piece.color == new Piece(0).color
    color = '黒' if piece.color == new Piece(1).color
    color


class Html extends OutputInterface
  constructor: ->

  show_piece: (piece) =>
    view = this._get_piece_type(piece)
    $('div#othello')
      .append('<p>')
      .append(view)


class Console extends OutputInterface
  constructor: ->

  show_piece: (piece) ->
    view = this._get_piece_type(piece)
    console.debug(view)

# }}}

# Player {{{
class Player
  ## field
  @order
  @piece
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
    cell = new Cell
    black = new Cell(0)
    white = new Cell(1)
    @cells =
      [[cell, cell, cell, cell, cell, cell, cell, cell]
      [cell, cell, cell, cell, cell, cell, cell, cell]
      [cell, cell, cell, cell, cell, cell, cell, cell]
      [cell, cell, cell, white, black, cell, cell, cell]
      [cell, cell, cell, black, white, cell, cell, cell]
      [cell, cell, cell, cell, cell, cell, cell, cell]
      [cell, cell, cell, cell, cell, cell, cell, cell]
      [cell, cell, cell, cell, cell, cell, cell, cell]]

class Cell
  constructor: (order = -1)->
    @piece = new Piece(order)

class Piece
  constructor: (order) ->
    return @color = 'void' if order == -1
    @color = Color.colors[order]

class Color
  @colors = ['white', 'black', 'blue', 'red']
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
