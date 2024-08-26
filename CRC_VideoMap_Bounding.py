import os
import sys
import geojson
from shapely.geometry import shape, box, mapping

def process_geojson(input_dir, output_dir, bounding_box):
    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)

    # Define the bounding box
    minx, miny, maxx, maxy = bounding_box
    bbox = box(minx, miny, maxx, maxy)

    # Process each GeoJSON file in the input directory
    for filename in os.listdir(input_dir):
        if filename.endswith('.geojson'):
            input_path = os.path.join(input_dir, filename)
            output_path = os.path.join(output_dir, filename.replace('.geojson', '_clipped.geojson'))
            
            with open(input_path, 'r') as infile:
                data = geojson.load(infile)
            
            # List to store features and features to prepend
            filtered_features = []
            features_to_prepend = []

            for feature in data['features']:
                geom = shape(feature['geometry'])
                
                if geom.is_empty:
                    continue
                
                # Check if the feature is a Point and has the specified properties
                if geom.geom_type == 'Point':
                    properties = feature.get('properties', {})
                    if any(properties.get(key) for key in ["isLineDefaults", "isSymbolDefaults", "isTextDefaults"]):
                        features_to_prepend.append(feature)
                        continue
                    # If it doesn't have those properties, check if it is within the bounding box
                    if bbox.contains(geom):
                        filtered_features.append(feature)
                        continue
                
                # Clip the geometry to the bounding box for other types
                clipped_geom = geom.intersection(bbox)
                
                if not clipped_geom.is_empty:
                    feature['geometry'] = mapping(clipped_geom)
                    filtered_features.append(feature)
            
            # Prepend the special features to the filtered list
            data['features'] = features_to_prepend + filtered_features
            
            # Save the filtered and clipped GeoJSON without pretty-printing
            with open(output_path, 'w') as outfile:
                geojson.dump(data, outfile)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python CRC_VideoMap_Bounding.py <input_dir> <output_dir> <bounding_coords>")
        sys.exit(1)
    
    input_dir = sys.argv[1]
    output_dir = sys.argv[2]
    bounding_coords_str = sys.argv[3]
    
    # Split the bounding_coords string into individual float values
    bounding_box = list(map(float, bounding_coords_str.split()))
    
    process_geojson(input_dir, output_dir, bounding_box)
