import json

def hex_to_rgb(hex_code):
    h = hex_code.lstrip('#')
    return [int(h[0:2], 16)/255.0, int(h[2:4], 16)/255.0, int(h[4:6], 16)/255.0, 1]

forest = hex_to_rgb('#2D6A4F')
trail = hex_to_rgb('#52B788')
summit = hex_to_rgb('#1B3A2D')
amber = hex_to_rgb('#D4A017')
blue = hex_to_rgb('#5B8DB8')

def rgb_to_hsl(r, g, b):
    maxc = max(r, g, b)
    minc = min(r, g, b)
    l = (maxc+minc)/2.0
    if maxc == minc:
        h = s = 0.0
    else:
        d = maxc - minc
        s = d/(2.0-maxc-minc) if l > 0.5 else d/(maxc+minc)
        if maxc == r: h = (g-b)/d + (6.0 if g < b else 0.0)
        elif maxc == g: h = (b-r)/d + 2.0
        else: h = (r-g)/d + 4.0
        h /= 6.0
    return h, s, l

def is_blue(r, g, b):
    h, s, l = rgb_to_hsl(r, g, b)
    return 0.5 <= h <= 0.7  # Blue hue range

def map_colors(file):
    with open(file, 'r') as f:
        data = json.load(f)
    
    def process_node(node):
        if isinstance(node, dict):
            if node.get('ty') == 'fl':
                c = node.get('c', {}).get('k')
                if isinstance(c, list) and len(c) == 4:
                    if is_blue(c[0], c[1], c[2]):
                        # Replace blue with forest green
                        node['c']['k'] = forest
            # We already fixed black floor for traveller, no need to touch again
            for k, v in node.items():
                process_node(v)
        elif isinstance(node, list):
            for item in node:
                process_node(item)
    
    process_node(data)
    with open(file, 'w') as f:
        json.dump(data, f)
    print("Processed", file)

map_colors('assets/animation/planning.json')
map_colors('assets/animation/traveller.json')
