window.othello = {}

# Othello 各インスタンスを生成, オセロの実行を行う{{{
class Othello
  run: ->
    @ready()
    @state = new Play @rule, @judge
    @state.exec()

  ready: ->
    Html.reset_html()
    @rule      = RuleCreater.make_rule Rule.get_rule_name()
    @judge     = new Judge @rule
    @state = new Ready @rule, @judge
    @state.exec()
# }}}

# GameState  {{{
class GameState
  constructor: (@rule, @judge)->
    @board = @rule.board
    @players = PlayerCreater.make_players @rule.player_num, @judge
    @outputer = new Html
    @pos = []
    @order = 0
  exec: ->

class Ready extends GameState
  exec: ->
    @outputer.set_board @board

class Play extends GameState
  exec: ->
    @players[@order % @rule.player_num].decide_pos @

  next: ->
    piece = @players[@order % @rule.player_num].piece
    if @judge.reverse @pos, piece
      Debug.html '[' + @order + ']' + @pos + ':' + piece.color
      @order++
    @outputer.update_board @board

class Reset extends GameState
  exec: ->

class Replay extends GameState
  exec: ->
# }}}

# Recoder {{{
class Recoder
  @order
  constructor: (players)->
    @order = 0
  recode: (pos, piece)->
# }}}

# Output オセロはこのクラスを用いて出力をする 静的クラスのほうがいい? {{{
class OutputInterface
  set_cell: (piece, pos)->

  set_board: (board)->
    height = board.cells.length
    for x in [0...height]
      width  = board.cells[x].length
      for y in [0...width]
        @set_cell board.cells[x][y].piece, [x, y]

  _get_piece_type: (piece)->
    color = 'void'  if piece.color == new Piece(-1).color
    color = 'white' if piece.color == new Piece(0).color
    color = 'black' if piece.color == new Piece(1).color
    color

class Html extends OutputInterface

  constructor: ()->
    @image_size = 50

  @reset_html: ()->
     $('.piece').remove()
     $('iframe:first').contents().find('li').remove()

  set_cell: (piece, pos)->
    [x, y] = Pos.calc_pos pos, @image_size
    color = @_get_piece_type piece
    $("<div class=\"piece #{color}\" id=#{pos[0]}_#{pos[1]}>")
      .css({
        backgroundPosition: '-' + x + 'px -' + y + 'px',
        top : x + 'px', left: y + 'px'
      }).hover(
        ->$(@).fadeTo("fast", 0.5),
        ->$(@).fadeTo("fast", 1.0)
      ).appendTo $('div#othello')

  update_board: (board)->
    for x in [0...board.height]
      for y in [0...board.width]
        id = Pos.pos2id [x, y]
        @change_color id, board.cells[x][y].piece.color

  change_color: (id, color)->
    content = $(id)
    content.removeClass "void"
    pos = Pos.id2pos id
    for c in Color.colors
      content.removeClass c
    content.addClass color
# }}}

# pos: 座標クラス {{{
class Pos
  @margin_top  : 50
  @margin_left : 0

  @pos2id: (pos)->
    [x, y] = pos
    id = '#' + x + '_' + y

  @id2pos: (id)->
    [id[1], id[3]]

  @pos2int: (str_pos)->
    [x, y] = str_pos
    pos = [parseInt(x), parseInt(y)]

  @calc_pos: (pos, size)->
    x = pos[0] * size + @margin_top
    y = pos[1] * size + @margin_left
    [x, y]

# }}}

# Player ボードにコマを置くクラス {{{
class Player
  constructor: (judge, @order)->
    @piece     = new Piece order

  decide_pos: ()->

class User extends Player
  decide_pos: (play)->
    pieces = $('.piece')
    for piece in pieces
      piece.onclick = (e)=>
        play.pos = Pos.pos2int [e.target.id[0], e.target.id[2]]
        play.next()

class Cpu extends Player
  decide_pos: ()->

class PlayerCreater
  @make_players: (num, judge)->
    players = []
    for k in [0...num]
      # TODO: ここでHTMLの要素参照してplayer_type取得
      players.push PlayerCreater.make_player 'user', judge, k
    players

  @make_player: (type, judge, order)->
    switch type
      when 'user' then new User judge, order
      when 'cpu'  then new Cpu  judge, order
# }}}

# Board オセロの各マス目を生成するクラス {{{
class Board
  constructor: (@rule)->
    @height = @rule.b_height
    @width  = @rule.b_width
    @cells = []
    for i in [0...@height]
      @cells[i] = []
      for j in [0...@width]
        @cells[i][j] = new Cell
    @cells[@height/2][@width/2]     = new Cell(0)
    @cells[@height/2-1][@width/2-1] = new Cell(0)
    @cells[@height/2][@width/2-1]   = new Cell(1)
    @cells[@height/2-1][@width/2]   = new Cell(1)

# Cell: オセロのマスを生成するクラス,置かれているピースの情報を知っている {{{
class Cell
  constructor: (order = -1)->
    @piece = new Piece(order)
#   }}}
# Piece: ピースを生成するクラス, 自分のピースの種類を知っている {{{
class Piece
  constructor: (order)->
    return @color = 'void' if order is -1
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
  constructor: (@rule)->
    @board = @rule.board

  # 8方向捜索
  reverse: (pos, piece)->
    result = false
    return result unless @rule.is_puttable pos
    for i in [-1..1]
      for j in [-1..1]
        continue if i is 0 and j is 0
        result = true if @_reverse_piece pos, [i, j], piece
    result

  _reverse_piece: (pos, dir, piece)->
    cells = @board.cells
    data = @rule.is_reverseble pos, dir, piece
    return false if not data['flag'] or data['cnt'] is 0
    cnt = data['cnt']
    [[hx, hy], [x, y]] = [pos, dir]
    loop
      cells[hx][hy].piece = piece
      [hx, hy] = [hx+x, hy+y]
      break if cnt-- <= 0
    return true
# }}}

# Rule: ボードを操作する際に必要な条件を持つクラス {{{
class Rule
  constructor: ()->
    @piece_num = @b_width * @b_height
    @user_piece_num = @piece_num / @player_num
    @board = new Board this

  @get_rule_name: ->
    return $('#rule')[0].value

  is_puttable: (pos)->
    [x, y] = pos
    return false unless @_is_inboard(pos)
    return false if @_is_putted(@board.cells[x][y].piece)
    true

  is_reverseble: (pos, dir, piece)->
    cells = @board.cells
    [[px, py], [x, y]] = [pos, dir]
    cnt = 0
    loop
      [px, py] = [px+x, py+y]
      return { flag: false } unless @_is_inboard [px, py]
      target = cells[px][py].piece
      return { flag: false } if @_is_empty target
      if @is_same_piece target, piece
        break
      else
        cnt++
    return { flag: true, pos: [px, py], cnt: cnt }

  is_same_piece: (piece, mypiece)->
    piece.color is mypiece.color and piece.color isnt 'void'

  _is_putted: (piece)->
    piece.color isnt 'void'

  _is_empty: (piece)->
    piece.color is 'void'

  _is_inboard: (pos)->
    [x, y] = pos
    return x >= 0 and x < @b_height and y >= 0 and y < @b_width

class NormalRule extends Rule
  b_width  : 8
  b_height : 8
  player_num : 2
  constructor: ()->
    super()

class HogeRule extends Rule
  b_width  : 4
  b_height : 8
  player_num : 2
  constructor: ()->
    super()

class RuleCreater
  @make_rule: (name)->
    switch name
      when "normal" then new NormalRule
      when "hoge" then new HogeRule
      # you should to add the original rule class
# }}}

# Debug: {{{
class Debug
  @cnt : 0
  @cells: (cells, message = 'debug')->
    console.debug message + '(cnt)' + (++@cnt) + '--------'
    for line in cells
      for cell in line
        console.debug cell.piece.color
  @html: (text)->
    $('<li>').text(text)
      .appendTo $('iframe:first').contents().find('body')
# }}}

window.othello = new Othello
$ ->
  $('#start').click ->
    window.othello.run()

  $('#reset').click ->
    window.othello.ready()

