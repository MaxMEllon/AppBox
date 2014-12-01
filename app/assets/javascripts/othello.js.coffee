# Othello {{{
class Othello
  constructor: ->
    # TODO:htmlの要素からルールを選択できるように
    @rule      = new NormalRule
    @board     = new Board @rule.b_height, @rule.b_width
    @judge     = new Judge @rule, @board
    @outputer  = new Html @judge
    # TODO:htmlの要素からプレイヤーを選択できるように
    @players = [new User(@judge, 0), new User(@judge, 1)]

  run: ->
    @outputer.show_board @board
    @players[0].put_piece()

# }}}

# Input {{{
class InputInterface

class Ai extends InputInterface
  constructor: ->
  select_piece_listener: ->

class Mouse extends InputInterface
  constructor: (judge)->
    @judge = judge
    @outputer  = new Html judge

  input: (pos)->
    console.debug pos
    @judge.reverse pos, new Piece(0)

# }}}

# Output {{{
class OutputInterface
  show_cell: (piece, pos) ->

  show_board: (board) ->
    height = board.cells.length
    width =  board.cells[0].length
    for x in [0...height]
      for y in [0...width]
        @show_cell board.cells[x][y].piece, [x, y]

  _get_piece_type: (piece) ->
    color = 'void'  if piece.color == new Piece(-1).color
    color = 'white' if piece.color == new Piece(0).color
    color = 'black' if piece.color == new Piece(1).color
    color

class Html extends OutputInterface

  constructor: (judge) ->
    @image_size = 50
    @judge = judge

  show_cell: (piece, pos) =>
    [x, y] = this._calc_pos pos
    color = this._get_piece_type piece
    $("<div class=\"piece #{color}\" id=#{pos[0]}_#{pos[1]}>")
      .css({
        backgroundPosition: '-' + x + 'px -' + y + 'px',
        top : x + 'px',
        left: y + 'px'
      })
      .appendTo $('div#othello')

  animation: (pos) ->
    id = '#' + pos[0] + '_' + pos[1]
    $(id).fadeTo(100, 0.5)

  change_color: (content, color) ->
    content.removeClass "void"
    for c in Color.colors
      content.removeClass c
    content.addClass color

  _calc_pos: (pos) ->
    x = pos[0] * @image_size
    y = pos[1] * @image_size
    [x, y]

class Console extends OutputInterface
  constructor: ->

  show_cell: (piece, pos) ->
    view = this._get_piece_type piece
    console.debug "[#{pos[0]}:#{pos[1]}]#{view}"
# }}}

# Player {{{
class Player
  put_piece: ->

class User extends Player
  constructor: (judge, order) ->
    @inputer   = new Mouse judge
    @piece     = new Piece order
    @order     = order

  put_piece: ()->
    pieces = $('.piece')
    $.each pieces, ->
      $(this).on 'click', =>
        pos = [this.id[0], this.id[2]]
        @inputer.click pos

class Cpu extends Player
  constructor: (piece_num, order) ->
    @inputer   = new Ai

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
    #     : 本来ならボードの初期形状はルールに依存するべきでは?
    @onboard_piece_num
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
  constructor: (rule, board)->
    @rule = rule
    @board = board

  is_puttable: (pos)->
    [x, y] = pos
    return false unless @rule.is_inboard(pos)
    return false if @rule.is_putted(pos, @board.cells[x][y])
    true

  reverse: (pos, piece) ->
    for i in [-1..1]
      for j in [-1..1]
        continue if i == 0 and j == 0
        this._reverse_piece(pos, [i, j], @board.cells, piece)

  _reverse_piece: (pos, dir, cells, piece) ->
    [hx, hy] = [px, py] = pos
    [x, y] = dir
    outputer = new Html this # TODO: 仮

    # 対岸のpieceの探索
    loop
      [px, py] = [px+x, py+y]
      return null unless @rule.is_inboard [px, py]
      target = cells[px][py].piece
      # 空白のマスもしくは自分自身のピースと衝突で探索打切
      break if target.color == piece.color

    # 打切ったときのマスが自分自身なら裏返し処理実行
    goal = cells[px][py].piece.color
    if goal == piece.color
      loop
        console.debug [hx, hy], cells[hx][hy].piece, piece
        cells[hx][hy].piece = piece
        id = '#' + hx + '_' + hy
        console.debug id
        outputer.change_color $(id), piece.color
        [hx, hy] = [hx+x, hy+y]
        break if hx == px and hy == py

class Rule
  @b_width
  @b_height
  @player_num
  @piece_num

  is_putted: (pos, board) ->

class NormalRule extends Rule
  constructor: ->
    @b_width = @b_height = 8
    @player_num = 2
    @piece_num = @b_width * @b_height
    @user_piece_num = @piece_num / @player_num

  is_putted: (pos, cell) ->
    [x, y] = pos
    cell.piece.color != 'void'

  is_inboard: (pos) ->
    [x, y] = pos
    return x >= 0 && x < @b_height && y >= 0 && y < @b_width

  is_reverseble: (pos, board) ->

# }}}

class Debug
  constructor: () ->

@othello = new Othello
