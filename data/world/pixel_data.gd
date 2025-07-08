class_name PixelData extends RefCounted

# WARNING very large datastore - do not open this resource in the editor
# holds an in-memory reference to every pixel in the world map and its color

var datastore: Dictionary[Vector2i, Color]
