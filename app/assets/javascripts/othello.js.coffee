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
  constructor: (judge)->
    @judge = judge

  input: (pos, piece)->
    console.debug "clicked : ", pos
    @judge.reverse pos, piece

# }}}

# Output オセロはこのクラスを用いて出力をする {{{
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

# Player ボードにコマを置くクラス {{{
class Player
  put_piece: ->
  _pos2int: (str_pos) ->
    [x, y] = str_pos
    pos = [parseInt(x), parseInt(y)]

class User extends Player
  constructor: (judge, order) ->
    @inputer   = new Mouse judge
    @piece     = new Piece order
    @order     = order

  put_piece: ()->
    pieces = $('.piece')
    for piece in pieces
      piece.onclick = (e) =>
        e.preventDefault  # よく理解していない 親オブジェクトのイベント中止？
        pos = @_pos2int [e.target.id[0], e.target.id[2]]
        @inputer.input pos, @piece

    #--- _thisへの退避がおかしく, アクセス出来ない {{{
    # $.each pieces, ->
    #   $(@).on 'click', =>
    #     pos = [@id[0], @id[2]]
    #     @inputer.click pos, @piece }}}

class Cpu extends Player
  constructor: (piece_num, order) ->
    @inputer   = new Ai

# }}}
# Board オセロの各マス目を生成するクラス {{{
class Board
  constructor: (rule) ->
    _height = rule.b_height
    _width = rule.b_width
    cell = new Cell
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
  constructor: (rule, board)->
    @rule = rule
    @board = board

  # 八方
  reverse: (pos, piece) ->
    return false unless @rule.is_puttable pos, @board
    for i in [-1..1]
      for j in [-1..1]
        continue if i == 0 and j == 0
        this._reverse_piece pos, [i, j], @board.cells, piece

  _reverse_piece: (pos, dir, cells, piece) ->
    [hx, hy] = [px, py] = pos
    [x, y] = dir
    outputer = new Html # TODO: 仮
    debug = new Debug
    reverseble_flag = false
    ## TODO: メソッドを分割する
    ## Rule.is_reverseble へ ----------
    # 対岸のpieceの探索
    loop
      [px, py] = [px+x, py+y]
      # 空白または範囲外で中止
      return false unless @rule.is_inboard [px, py]
      return false if cells[px][py].piece.color == 'void'
      reverseble_flag = true if cells[px][py].piece.color != piece.color
      target = cells[px][py].piece
      # 自分自身のピースと衝突で探索打切
      break if target.color == piece.color
    ##--------------------------------
    # 打切したときのマスが自分自身なら裏返し処理実行
    end = cells[px][py].piece.color
    console.debug reverseble_flag, end == piece.color
    if reverseble_flag and end == piece.color
      loop
        # TODO: ここで代入するとcell全体にpieceが置かれてしまう
        cells[hx][hy].piece = piece
        console.debug cells[hx][hy].piece
        ## TODO: ここで描画処理を呼びたくない(関連を減らすために?) {{{
        id = '#' + hx + '_' + hy
        outputer.change_color $(id), piece.color
        ##-------------------------------------------------------- }}}
        [hx, hy] = [hx+x, hy+y]
        console.debug "hx:hy", [hx, hy]
        break if hx == px and hy == py
    ##--------------------------------
      return true
    false
# }}}

# Rule: ボードを操作する際に必要な条件を持つクラス {{{
class Rule
  @b_width
  @b_height
  @player_num
  @piece_num
  @user_piece_num

  is_puttable: (pos, board)->
    [x, y] = pos
    return false unless @is_inboard(pos)
    return false if @is_putted(pos, board.cells[x][y])
    true

  is_putted: (pos, cell) ->
    [x, y] = pos
    cell.piece.color != 'void'

  is_inboard: (pos) ->
    [x, y] = pos
    return x >= 0 && x < @b_height && y >= 0 && y < @b_width

  is_reverseble: (pos, dir, board) ->

class NormalRule extends Rule
  constructor: ()->
    @b_width = @b_height = 8
    @player_num = 2
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
