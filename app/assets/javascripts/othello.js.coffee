# Othello 各インスタンスを生成, オセロの実行を行う{{{
class Othello
  constructor: ->
    # TODO: htmlの要素からルールを選択できるように
    @rule      = new NormalRule
    @board     = new Board @rule
    @judge     = new Judge @rule, @board
    @outputer  = new Html
    # TODO: htmlの要素からプレイヤーを選択できるように
    @players = [new User(@judge, 0), new User(@judge, 1)]

  run: ->
    @outputer.show_board @board
    # TODO: 交互に呼びたい(0番プレーヤが終わったら1番プレーヤへ)
    @players[0].put_piece()
# }}}

# InputInterface ユーザはこのクラスを用いて座標の入力をする{{{
class InputInterface

class Ai extends InputInterface
  constructor: ->
  select_piece_listener: ->

class Mouse extends InputInterface
  constructor: (@judge)->

  input: (pos, piece)->
    console.debug "clicked : ", pos
    @judge.reverse pos, piece
# }}}

# Output オセロはこのクラスを用いて出力をする {{{
class OutputInterface
  show_cell: (piece, pos) ->

  show_board: (board) ->
    height = board.cells.length
    width  = board.cells[0].length
    for x in [0...height]
      for y in [0...width]
        @show_cell board.cells[x][y].piece, [x, y]

  _get_piece_type: (piece) ->
    color = 'void'  if piece.color == new Piece(-1).color
    color = 'white' if piece.color == new Piece(0).color
    color = 'black' if piece.color == new Piece(1).color
    color

class Html extends OutputInterface

  constructor: () ->
    @image_size = 50

  show_cell: (piece, pos) =>
    [x, y] = @_calc_pos pos
    color = @_get_piece_type piece
    # TODO: スッキリ書く方法があればそれに変更
    $("<div class=\"piece #{color}\" id=#{pos[0]}_#{pos[1]}>")
      .css({
        backgroundPosition: '-' + x + 'px -' + y + 'px',
        top : x + 'px',
        left: y + 'px'
      })
      .appendTo $('div#othello')

  animation: (pos) ->
    id = @pos2id pos
    $(id).fadeTo(100, 0.5)

  change_color: (id, color) ->
    content = $(id)
    content.removeClass "void"
    for c in Color.colors
      content.removeClass c
    content.addClass color

  pos2id: (pos) ->
    [x, y] = pos
    id = '#' + x + '_' + y

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

# Player ボードにコマを置くクラス {{{
class Player
  put_piece: ->
  _pos2int: (str_pos) ->
    [x, y] = str_pos
    pos = [parseInt(x), parseInt(y)]

class User extends Player
  constructor: (judge, @order) ->
    @inputer   = new Mouse judge
    @piece     = new Piece order

  put_piece: ()->
    pieces = $('.piece')
    for piece in pieces
      piece.onclick = (e) =>
        e.preventDefault  # よく理解していない 親オブジェクトのイベント中止？
        pos = @_pos2int [e.target.id[0], e.target.id[2]]
        @inputer.input pos, @piece

class Cpu extends Player
  constructor: (piece_num, order) ->
    @inputer   = new Ai

# }}}

# Board オセロの各マス目を生成するクラス {{{
class Board
  constructor: (@rule) ->
    _height = @rule.b_height
    _width  = @rule.b_width
    cell  = new Cell
    white = new Cell(0)
    black = new Cell(1)

    # TODO: 頭のいい初期化の方法に変えたい
    #     : 本来ならボードの初期形状はルールに依存するべきでは?
    #     : でもルールを作るのにボードが必要
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

# Cell: オセロのマスを生成するクラス,置かれているピースの情報を知っている {{{
class Cell
  constructor: (order = -1)->
    @piece = new Piece(order)
#   }}}
# Piece: ピースを生成するクラス, 自分のピースの種類を知っている {{{
class Piece
  constructor: (order) ->
    return @color = 'void' if order == -1
    @color = Color.colors[order]
#   }}}
# Color オセロに登場する色の全種類の名前を知っている{{{
class Color
  # 青や赤は色物ルール用
  @colors = ['white', 'black', 'blue', 'red']
#   }}}
# }}}

# Judge: 正確にゲームを運べるようにボードへの操作をする {{{
class Judge
  constructor: (@rule, @board)->
    @outputer = new Html

  # 八方
  reverse: (pos, piece) ->
    return false unless @rule.is_puttable pos, @board
    for i in [-1..1]
      for j in [-1..1]
        continue if i == 0 and j == 0
        this._reverse_piece pos, [i, j], @board.cells, piece

  _reverse_piece: (pos, dir, cells, piece) ->
    [px, py] = @rule.is_reverseble(pos, dir, cells, piece)
    return false unless px? or py?
    [hx, hy] = pos
    [x, y] = dir
    console.debug "p", [px, py], "h", [hx, hy], "dir", [x, y]
    end = cells[px][py].piece
    if @rule.is_same_piece end, piece
      loop
        console.debug "h", [hx, hy]
        # cells[hx][hy].piece = piece
        console.debug [hx, hy], cells[hx][hy].piece, piece
        id = @outputer.pos2id [hx, hy]
        @outputer.change_color id, piece.color
        [hx, hy] = [hx+x, hy+y]
        break if hx == px and hy == py
      return true
    false
# }}}

# Rule: ボードを操作する際に必要な条件を持つクラス {{{
class Rule

  is_puttable: (pos, board)->
    [x, y] = pos
    return false unless @_is_inboard(pos)
    return false if @_is_putted(board.cells[x][y].piece)
    true

  # 裏返すことができる時trueではなく，座標を返しているのに注意
  is_reverseble: (pos, dir, cells, piece) ->
    [hx, hy] = [px, py] = pos
    [x, y] = dir
    reverseble_flag = false
    loop
      [px, py] = [px+x, py+y]
      return false unless @_is_inboard [px, py]
      target = cells[px][py].piece
      return false unless @_is_putted target
      break if @is_same_piece target, piece
    return [px, py]
    false

  is_same_piece: (piece, mypiece) ->
    piece.color == mypiece.color

  _is_putted: (piece) ->
    piece.color != 'void'

  _is_inboard: (pos) ->
    [x, y] = pos
    return x >= 0 && x < @b_height && y >= 0 && y < @b_width


class NormalRule extends Rule
  b_width  : 8
  b_height : 8
  player_num : 2
  constructor: ()->
    @piece_num = @b_width * @b_height
    @user_piece_num = @piece_num / @player_num
# }}}

# Debug: {{{
class Debug
  constructor: () ->
  board: (cells) ->
    for line in cells
      for cell in line
        console.debug cell.piece.color
# }}}

@othello = new Othello
