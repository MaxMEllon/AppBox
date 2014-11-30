# Othello {{{

class Othello
  constructor: ->
    @judge = new Judge('normal')   # TODO:htmlの要素から選択できるように
    @outputer = new Html(@judge.rule.piece_num)
    @board = new Board(@judge.rule.b_height, @judge.rule.b_width)
    @player = []
    for k in [0...@judge.rule.player_num]
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
  show_piece: (piece, pos) ->

  show_board: (board) ->
    height = board.cells.length
    width =  board.cells[0].length
    for x in [0...height]
      for y in [0...width]
        pos = [x, y]
        @show_piece(board.cells[x][y].piece, pos)

  _get_piece_type: (piece) ->
    color = 'void'  if piece.color == new Piece(-1).color
    color = 'white' if piece.color == new Piece(0).color
    color = 'black' if piece.color == new Piece(1).color
    color

class Html extends OutputInterface

  constructor: (piece_num = 8) ->
    @window_size = piece_num * this._image_size
    _image_size = 50

  show_piece: (piece, pos) =>
    [x, y] = this._calc_pos(pos)
    color = this._get_piece_type(piece)
    $("<div class=\"piece #{color}\" id=#{x}_#{y}>")
      .css({
        backgroundPosition: '-' + x + 'px -' + y + 'px',
        top : x + 'px',
        left: y + 'px'
      })
      .appendTo($('div#othello'))

  _calc_pos: (pos) ->
    x = pos[0] * this._image_size
    y = pos[1] * this._image_size
    x = pos[0] * 50
    y = pos[1] * 50
    console.debug(pos[0], pos[1], x, y, this._image_size)
    [x, y]

class Console extends OutputInterface
  constructor: ->

  show_piece: (piece, pos) ->
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
