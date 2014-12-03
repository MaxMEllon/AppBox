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
      .hover(
        ->$(this).fadeTo("fast", 0.5),
        ->$(this).fadeTo("fast", 1.0)
      )
      .text piece.color + pos
      .appendTo $('div#othello')

  update_board: (board) ->
    # height = board.cells.length
    # width  = board.cells[0].length
    for x in [0...board.height]
      for y in [0...board.width]
        id = Html.pos2id [x, y]
        @change_color id, board.cells[x][y].piece.color

  change_color: (id, color) ->
    content = $(id)
    content.removeClass "void"
    pos = Html.id2pos id
    content.text color + pos
    for c in Color.colors
      content.removeClass c
    content.addClass color

  @pos2id: (pos) ->
    [x, y] = pos
    id = '#' + x + '_' + y

  @id2pos: (id) ->
    [id[1], id[3]]

  @pos2int: (str_pos) ->
    [x, y] = str_pos
    pos = [parseInt(x), parseInt(y)]

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

class User extends Player
  constructor: (judge, @order) ->
    @inputer   = new Mouse judge
    @piece     = new Piece order

  put_piece: ()->
    pieces = $('.piece')
    for piece in pieces
      piece.onclick = (e) =>
        pos = Html.pos2int [e.target.id[0], e.target.id[2]]
        @inputer.input pos, @piece

class Cpu extends Player
  constructor: (piece_num, order) ->
    @inputer   = new Ai

# }}}

# Board オセロの各マス目を生成するクラス {{{
class Board
  constructor: (@rule) ->
    @height = @rule.b_height
    @width  = @rule.b_width
    @cells = []
    for i in [0...@height]
      @cells[i] = []
      for j in [0...@width]
        @cells[i][j] = new Cell
    [x, y] = [@height/2, @width/2-1]
    @cells[x][x] = new Cell(0)
    @cells[y][y] = new Cell(0)
    @cells[x][y] = new Cell(1)
    @cells[y][x] = new Cell(1)

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

  # 8方向捜索
  reverse: (pos, piece) ->
    return false unless @rule.is_puttable pos, @board
    for i in [-1..1]
      for j in [-1..1]
        # Debug.cells(@board.cells) # 裏返した次のループからバグってる
        continue if i == 0 and j == 0
        this._reverse_piece pos, [i, j], @board.cells, piece
    @outputer.update_board @board

  _reverse_piece: (pos, dir, cells, piece) ->
    data = @rule.is_reverseble pos, dir, cells, piece
    return false if ! data['flag'] or data['cnt'] == 0
    console.debug cnt = data['cnt']
    [[hx, hy], [x, y]] = [pos, dir]
    loop
      cells[hx][hy].piece = piece
      [hx, hy] = [hx+x, hy+y]
      break if cnt-- <= 0
# }}}

# Rule: ボードを操作する際に必要な条件を持つクラス {{{
class Rule
  is_puttable: (pos, board)->
    [x, y] = pos
    return false unless @_is_inboard(pos)
    return false if @_is_putted(board.cells[x][y].piece)
    true

  is_reverseble: (pos, dir, cells, piece) ->
    [px, py] = pos
    [x, y] = dir
    cnt = 0
    loop
      [px, py] = [px+x, py+y]
      return { flag: false } unless @_is_inboard [px, py]
      target = cells[px][py].piece
      return { flag: false } if target.color == 'void'
      cnt++ unless @is_same_piece target, piece
      break if @is_same_piece target, piece
    return { flag: true, pos: [px, py], cnt: cnt }

  is_same_piece: (piece, mypiece) ->
    piece.color == mypiece.color and piece.color != 'void'

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
  @cnt : 0
  @cells: (cells, message = 'debug')  ->
    console.debug message + '(cnt)' + (++@cnt) + '-----------------------'
    for line in cells
      for cell in line
        console.debug cell.piece.color
# }}}

@othello = new Othello
