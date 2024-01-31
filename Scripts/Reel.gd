extends Node2D
@export var slotItemCount : int = 10
@export var spriteSize  : int = 16
@onready var reel1 = $reelImage1
@onready var reel2 = $reelImage2
var TWN
var MS = 20
var state 
enum {ROLL,STOP,ROLLBACK}
var rollDuration = 3
var rollBackDuration =0.5
@export var reelID:int
# Called when the node enters the scene tree for the first time.
func _ready():
	SigBank.startRoll.connect(Callable(self,"_startRoll"))
	reel1.position.y = -1000
	reel2.position.y = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("ui_accept"):
		_startRoll(reelID,5)
		print("rollMe")
	
	match state:
		ROLLBACK:
			_roll(reel1,-MS)
			_roll(reel2,-MS)
			
			rollBackDuration -= delta
			if rollBackDuration <= 0:
				state = ROLL
		ROLL:
			_roll(reel1,MS)
			_roll(reel2,MS)
			
			rollDuration -= delta
			if rollDuration <= 0:
				state = STOP
				_stopRoll()
		STOP:
			pass
	

func _startRoll(reelNumber,dur):
	if reelNumber!= reelID : return
	
	reel1.position.y = -1000
	reel2.position.y = 0
	state = ROLLBACK
	rollDuration = dur
	print(reelID,reelNumber,dur)
	rollBackDuration = 0.25
	

func _roll(slot:Sprite2D,MSpeed):
	var newPOS2 = slot.position.y + MSpeed
	if newPOS2 >= 1000:
		newPOS2 =-1000
	slot.position.y = newPOS2

func _stopRoll():
	TWN = create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT).set_parallel()
	var rng = randi_range(0,9)
	var dur = 1.5

	var finalPos = -100*rng
	
	var finalSlot
	var anotherSlot
	if reel1.position.y < reel2.position.y:
		finalSlot = reel1
		anotherSlot = reel2
	else:
		finalSlot = reel2
		anotherSlot = reel1
	
	finalSlot.z_index = 1
	anotherSlot.z_index = 0
	TWN.tween_property(finalSlot,"position:y",finalPos,dur)
	TWN.tween_property(anotherSlot,"position:y",finalPos+1000,dur)
	await TWN.finished
	print("Reeel ID",reelID," reel Image ", finalSlot.name ," POS : ",finalPos, " RNJESUS :",rng)
	SigBank.rollFinished.emit(reelID,rng)
