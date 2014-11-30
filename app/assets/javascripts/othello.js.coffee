# Othello {{{

class Othello
  constructor: ->
    # TODO:htmlの要素からルールを選択できるように
    @judge     = new Judge('normal')
    @outputer  = new Html(@judge.rule.piece_num)
    @board     = new Board(@judge.rule.b_height, @judge.rule.b_width)
    # TODO:htmlの要素からプレイヤーを選択できるように
    p_num = @judge.rule.user_piece_num
    @player = [new User(p_num, 0), new User(p_num, 1)]
  run: ->
    @outputer.show_board(@board)
    # QUESTION:イベントハンドラはここで呼ばないと動かない？
    @player[0].inputer.select_piece_listener()
# }}}

# Input {{{
class InputInterface

class Ai extends InputInterface
  constructor: ->
  select_piece_listener: ->

class Mouse extends InputInterface
  constructor: ->
  select_piece_listener: ->
    outputer = new Html
    pieces = $('.piece')
    $.each pieces, ->
      $(this).on 'click', ->
        @pos = [this.id[0], this.id[2]]
        outputer.animation(@pos)
# }}}

# Output {{{
class OutputInterface
  show_piece: (piece, pos) ->

  show_board: (board) ->
    height = board.cells.length
    width =  board.cells[0].length
    for x in [0...height]
      for y in [0...width]
        @show_piece(board.cells[x][y].piece, [x, y])

  _get_piece_type: (piece) ->
    color = 'void'  if piece.color == new Piece(-1).color
    color = 'white' if piece.color == new Piece(0).color
    color = 'black' if piece.color == new Piece(1).color
    color

class Html extends OutputInterface

  constructor: (piece_num = 8) ->
    @window_size = piece_num * this._image_size
    @image_size = 50

  show_piece: (piece, pos) =>
    [x, y] = this._calc_pos(pos)
    color = this._get_piece_type(piece)
    $("<div class=\"piece #{color}\" id=#{pos[0]}_#{pos[1]}>")
      .css({
        backgroundPosition: '-' + x + 'px -' + y + 'px',
        top : x + 'px',
        left: y + 'px'
      })
      .appendTo($('div#othello'))

  animation: (pos) ->
    id = '#' + pos[0] + '_' + pos[1]
    $(id).fadeTo(100, 0.5)

  _calc_pos: (pos) ->
    x = pos[0] * @image_size
    y = pos[1] * @image_size
    [x, y]

class Console extends OutputInterface
  constructor: ->

  show_piece: (piece, pos) ->
    view = this._get_piece_type(piece)
    console.debug("[#{pos[0]}:#{pos[1]}]#{view}")
# }}}

# Player {{{
class Player
  decide_hand: ->

class User extends Player
  constructor: (piece_num, order) ->
    @inputer   = new Mouse
    @piece_num = piece_num
    @order     = order
  decide_hand: ->

class Cpu extends Player
  constructor: (piece_num, order) ->
    @inputer   = new Ai
    @piece_num = piece_num
    @order     = order

# }}}

# Board {{{
class Board
  constructor: (height, width) ->
    _height = height
    _width = width
    cell = new Cell
    black = new Cell(0)
    white = new Cell(1)
    # TODO: 頭のいい初期化の方法に変えたい
    @cells =
      [[cell, cell, cell, cell,  cell,  cell, cell, cell]
       [cell, cell, cell, cell,  cell,  cell, cell, cell]
       [cell, cell, cell, cell,  cell,  cell, cell, cell]
       [cell, cell, cell, white, black, cell, cell, cell]
       [cell, cell, cell, black, white, cell, cell, cell]
       [cell, cell, cell, cell,  cell,  cell, cell, cell]
       [cell, cell, cell, cell,  cell,  cell, cell, cell]
       [cell, cell, cell, cell,  cell,  cell, cell, cell]]

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
    @user_piece_num = @piece_num / @player_num
# }}}

@othello = new Othello
