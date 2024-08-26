# CRC Video Map Bounding

This script is designed to process GeoJSON files (specifically those meant for the CRC program) containing various geographical features such as LineStrings, MultiLineStrings, and Points. The primary objective of this script is to filter and retain only the portions of these features that fall within a user-defined bounding box. Certain Point features with specific properties (CRC ERAM Defaults Feature) are always retained and placed at the beginning of the feature collection.

## Requirements

- Python 3.x
- Libraries:
  - `geojson`
  - `shapely`

Using the `Run_CRC_VideoMap_Bounding.bat` checks your system to make sure the appropriate installations are present.

You can install the necessary libraries with the following CMD prompt line or just run the `Run_CRC_VideoMap_Bounding.bat` and it will do this for you:

```bash
pip install geojson shapely
```

## Script Usage

### Batch File

1. Download the [Run_CRC_VideoMap_Bounding.bat](https://github.com/KSanders7070/CRC_VideoMap_Bounding/releases/latest/download/Run_CRC_VideoMap_Bounding.bat) file and the [CRC_VideoMap_Bounding.py](https://github.com/KSanders7070/CRC_VideoMap_Bounding/releases/latest/download/CRC_VideoMap_Bounding.py) file and make sure they are in the same folder as each other.
2. Ensure all the .geojsons you want to be bounded/clipped are in the same directory as each other.
3. Input the bounding-box coordinates as instructed.
4. Run the `Run_CRC_VideoMap_Bounding.bat`, select the directory hosting the .geojsons you want bounded/clipped and choose an output directory.

### Command Line Arguments

If you choose to not use the .bat file, the script expects the following command-line arguments:

1. **Input Directory**: Directory containing the `.geojson` files to be processed.
2. **Output Directory**: Directory where the processed files will be saved.
3. **Bounding Box Coordinates**: A string of four space-separated float values representing the bounding box in the order: `minx miny maxx maxy`.

Example:

```bash
python CRC_VideoMap_Bounding.py "C:\path\to\input_dir" "C:\path\to\output_dir" "-84.20559203427143 39.75987383567464 -81.61735880309048 41.46992782488129"
```

## Script Details

### Filtering Logic

The script processes each GeoJSON file in the input directory, performing the following actions:

1. **Bounding Box Filtering**:
   - Retains only the features that are within or intersect with the bounding box.
   - Clips LineStrings and MultiLineStrings to the bounding box boundaries.

2. **Point Feature Prepending**:
   - Retains and prepends Point features that meet the following criteria:
     - `"type":"Point"`
     - Contain any of the following properties:
       - `"isLineDefaults": true`
       - `"isSymbolDefaults": true`
       - `"isTextDefaults": true`

## File Name Clean up

If you wish to have the "_clipped" removed from the file names after the process is complete, consider use the script found here:
https://github.com/KSanders7070/Rename_File_Name_Prefix_Suffix
