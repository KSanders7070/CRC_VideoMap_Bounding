import os
import sys
import geojson
from shapely.geometry import shape, box, mapping
from shapely.ops import clip_by_rect

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
            output_path = os.path.join(output_dir, filename.replace('.geojson', '_converted.geojson'))
            
            with open(input_path, 'r') as infile:
                data = geojson.load(infile)
            
            # Filter and clip features based on the bounding box
            filtered_features = []
            for feature in data['features']:
                geom = shape(feature['geometry'])
                
                if geom.is_empty:
                    continue
                
                # If it's a Point with specific properties, always retain it
                if geom.type == 'Point':
                    # Add condition for retaining specific points here
                    # Example: if feature['properties'].get('retain', False):
                    #     filtered_features.append(feature)
                    filtered_features.append(feature)
                    continue
                
                # Clip the geometry to the bounding box
                clipped_geom = geom.intersection(bbox)
                
                if not clipped_geom.is_empty:
                    # Update the geometry in the feature with the clipped geometry
                    feature['geometry'] = mapping(clipped_geom)
                    filtered_features.append(feature)
            
            # Save the filtered and clipped GeoJSON
            data['features'] = filtered_features
            with open(output_path, 'w') as outfile:
                geojson.dump(data, outfile, indent=2)

if __name__ == "__main__":
    # Example usage: python CRC_VideoMap_Bounding.py input_dir output_dir bounding_coords
    if len(sys.argv) != 4:
        print("Usage: python CRC_VideoMap_Bounding.py <input_dir> <output_dir> <bounding_coords>")
        sys.exit(1)
    
    input_dir = sys.argv[1]
    output_dir = sys.argv[2]
    bounding_coords_str = sys.argv[3]
    
    # Split the bounding_coords string into individual float values
    bounding_box = list(map(float, bounding_coords_str.split()))
    
    process_geojson(input_dir, output_dir, bounding_box)
