extends Control

@export var change_interval: float = 0.1  # Interval waktu dalam detik
@export var next_scene: String = "res://Scenes/mainMenu.tscn"  # Path ke scene berikutnya

var current_index: int = 1  # Mulai dari TextureRect bernama "1"

func _ready():
	# Pastikan TextureRect pertama diatur
	update_texture()

	# Buat timer untuk mengganti tekstur
	var timer = Timer.new()
	timer.wait_time = change_interval
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()

func _on_timer_timeout():
	# Perbarui indeks dan tampilkan TextureRect berikutnya
	current_index += 1
	if current_index > 11:
		# Jika sudah mencapai TextureRect "9", pindah ke scene berikutnya
		get_tree().change_scene_to_file("res://Scenes/mainMenu.tscn")
		return
	update_texture()

func update_texture():
	# Sembunyikan semua TextureRect
	for i in range(1, 12):
		var texture_rect = get_node_or_null(str(i))  # Akses node berdasarkan nama
		if texture_rect:
			texture_rect.visible = false
		else:
			print("Error: TextureRect with name '%s' not found." % i)

	# Tampilkan TextureRect saat ini
	var current_texture_rect = get_node_or_null(str(current_index))
	if current_texture_rect:
		current_texture_rect.visible = true
	else:
		print("Error: TextureRect with name '%s' not found." % current_index)
