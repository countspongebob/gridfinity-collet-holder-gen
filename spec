# Gridfinity Parametric Collet Holder Specification

## Overview
A parametric OpenSCAD design for creating Gridfinity-compatible holders for various collet types (ER-16, ER-20, ER-32, ER-40) with customizable grid sizes and ergonomic spacing.

## Design Requirements

## Design Requirements

### 1. Gridfinity Compatibility (Extended Standard)
- Base unit: 42mm x 42mm x 7mm (standard Gridfinity module)
- Base height: 5mm (standard)
- Corner radius: 3.75mm (outer), 1.6mm (bottom profile)
- Wall thickness: 1.2mm minimum
- Tolerance: 0.5mm for grid fitting
- Stacking features:
  - Bottom profile: 2.15mm deep recess, 0.95mm wall offset
  - Top lip: 0.7mm deep, 1.8mm wall width for bin stacking
- Magnet holes: 6.5mm diameter x 2.4mm deep at ±13.2mm from grid center
- Screw holes: 3mm diameter (optional, under magnets)

### 2. Supported Collet Types
| Collet Type | Outer Diameter (mm) | Height (mm) | Hole Reduction (mm) | Resulting Hole (mm) |
|-------------|-------------------|-------------|-------------------|-------------------|
| ER-11       | 11.5              | 28          | -2                | 9.5               |
| ER-16       | 17                | 30          | -3                | 14                |
| ER-20       | 21                | 32          | -3                | 18                |
| ER-25       | 26                | 34          | -4                | 22                |
| ER-32       | 33                | 40          | -5                | 28                |
| ER-40       | 41                | 46          | -6                | 35                |
| 5C          | 26                | 100         | -4                | 22                |
| R8          | 20                | 40          | -3                | 17                |
| SX10        | TBD               | TBD         | TBD               | TBD               |
| SX06        | TBD               | TBD         | TBD               | TBD               |

### 3. Parameters
- **Grid Size**
  - `grid_x`: Number of Gridfinity units in X direction (1-10)
  - `grid_y`: Number of Gridfinity units in Y direction (1-10)
  
- **Collet Selection**
  - `collet_type`: String ["ER-16", "ER-20", "ER-32", "ER-40"]
  
- **Layout Options**
  - `finger_clearance`: Additional space between holders (default: 3mm)
  - `holder_wall_thickness`: Wall thickness between holes (default: 2mm)
  - `holder_depth_ratio`: Depth as ratio of collet height (default: 0.75)
  
- **Gridfinity Features**
  - `add_magnets`: Boolean to include magnet holes (default: true)
  - `add_stacking_lip`: Boolean for top stacking lip (default: true)
  - `add_labels`: Boolean to add collet size labels (default: true)
  - `add_chamfer`: Boolean for hole entry chamfers (default: true)

### 4. Layout Algorithm
1. Calculate available space: `(grid_x * 42) x (grid_y * 42)` mm
2. Determine hole spacing: `collet_diameter + clearance + finger_clearance`
3. Calculate maximum collets per row/column
4. Center the array within the available space
5. Ensure minimum 5mm from grid edges
6. Optimize packing for maximum density while maintaining usability

### 5. Holder Design Details
- **Overall Design**: Single box with flat top surface containing holes
- **Base Section**: 5mm Gridfinity-compliant base with:
  - Bottom recess (2.15mm deep) for grid fitting
  - Optional top lip (0.7mm deep) for bin stacking
  - Magnet holes at standard positions
- **Box Height**: Base height (5mm) + holder depth + top thickness (3mm)
- **Hole Shape**: Tapered cylindrical holes with 8-degree half angle (16-degree included angle)
  - Bottom diameter: Collet diameter + clearance value
  - Top diameter: Calculated based on 8-degree taper
  - Matches standard ER collet taper
- **Hole Depth**: Adjustable via `holder_depth_ratio` parameter
- **Optional Chamfer**: Additional entry chamfer for easier insertion
- **Top Surface**: Flat solid surface with tapered holes
- **Label**: Embossed text on front face (if enabled)

### 6. Manufacturing Considerations
- Minimum wall thickness: 2mm
- Print orientation: Base down, no supports needed
- Layer height recommendation: 0.2mm
- Infill recommendation: 20-30%

## Change Log
### Version 1.8 (Current)
- Aligned with Gridfinity Extended OpenSCAD standards
- Proper base implementation with stacking features
- Correct magnet positioning at grid intersections
- Added optional screw holes under magnets
- Simplified but compliant base structure

### Version 1.1
- Changed design from individual holders to single box with holes
- Reduced default finger clearance from 8mm to 3mm for tighter packing
- Added top_thickness parameter
- Flat top surface design for cleaner appearance

### Version 1.0 (Initial)
- Basic gridfinity base implementation
- Support for 4 collet types
- Parametric grid sizing
- Automatic layout with finger clearance
- Optional features (magnets, labels, drainage)
