# Othello {{{
class Othello
  constructor: ->
    @judge = Judge.new('normal')   # TODO:htmlの要素から選択できるように
    @outputer = OutputText.new
    @board = Board.new(@judge.rule.b_width, @judge.rule.height)
  run: ->
    @board.show_board

# }}}

# Input {{{
class InputType

class Keyboard extends InputType
  constructor: ->
    null

class Mouse extends InputType
  constructor: ->
    null
# }}}

# Output {{{
class OutputType

class OutputImage extends OutputType
  ## field
  # image_size
  @width
  @height
  constructor: ->
    null

class OutputText extends OutputType
  constructor: ->

  @show_board: (board) ->
    # TODO:board.lengthを使う
    for x in [0..8]
      for y in [0..8]
        this.show_piece(board[x][y].piace)

  show_piece: (piece) ->
    console.debug('・') if piece == null
    console.debug('黒') if piece == 'black'
    console.debug('白') if piece == 'white'
# }}}

# Player {{{
class Player
  ## field
  @order
  @Piece
  constructor: ->
    null
  ## method
  dicide_hand: (x, y)->

class User extends Player
  ## method
  constructor: () ->
    null

class Computer extends Player
  constructor: () ->
    null
# }}}

# Board {{{
class Board
  constructor: (width, height) ->
    @cells = Cell[height][width].new

class Cell
  constructor: ->
    @piece = null

class Piece
  constructor: (order) ->
    @color = white if order == 0
    @color = black if order == 1
    null
# }}}

# Judge {{{
class Judge
  constructor: (type)->
    if type == 'normal'
      @rule = NormalRule.new

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

othello = Othello.new
othello.run

