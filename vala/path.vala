/*
 * SmartSim - Digital Logic Circuit Designer and Simulator
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *   Filename: path.vala
 *
 *   Copyright Ashley Newson 2013
 */


/**
 * Describes a path of straight lines.
 *
 * Used (sometimes in groups) to describe the structure of a wire.
 */
public class Path {
    /**
     * Describes starts and end points of a line with a description of
     * the lines orientation (horizontal, vertical, diagonal).
     */
    public struct Line {
        int x1;
        int y1;
        int x2;
        int y2;
        Direction dir;
    }

    /**
     * An array of lines create a multi-line (multi-point) path.
     */
    public Line[] lines;
    /**
     * The array index of the last line. set to -1 if there are none.
     */
    public int last;
    /**
     * The horizontal position of the last point.
     */
    public int xLast;
    /**
     * The vertical position of the last point.
     */
    public int yLast;
    /**
     * The horizontal position of the start point of the last line.
     * (The second-last point)
     */
    public int xLineStart;
    /**
     * The vertical position of the start point of the last line.
     * (The second-last point)
     */
    public int yLineStart;
    /**
     * The orientation (horizontal, vertical, diagonal) of the last
     * line.
     */
    public Direction dirLast;

    /**
     * Creates a new path which starts at (//xStart//, //yStart//).
     */
    public Path(int xStart, int yStart) {
        last = -1;
        xLast = xStart;
        yLast = yStart;
        xLineStart = xStart;
        yLineStart = yStart;
        dirLast = Direction.NONE;
    }

    public void merge(Path extraPath, bool prepend, bool reverse) {
        Line[] newLines;
        Line[] lastLines;
        Line[] extraLines;

        if (reverse) {
            extraLines = {};
            for (int i = extraPath.lines.length - 1; i >= 0; i--) {
                Line reversedLine = Line();
                reversedLine.x1 = extraPath.lines[i].x2;
                reversedLine.x2 = extraPath.lines[i].x1;
                reversedLine.y1 = extraPath.lines[i].y2;
                reversedLine.y2 = extraPath.lines[i].y1;
                reversedLine.dir = extraPath.lines[i].dir;

                extraLines += reversedLine;
            }
        } else {
            extraLines = extraPath.lines;
        }

        if (prepend) {
            newLines = extraLines;
            lastLines = lines;
        } else {
            newLines = lines;
            lastLines = extraLines;
        }

        for (int i = 0; i < lastLines.length; i++) {
            if (i == 0) {
                int lastNew = newLines.length - 1;
                if (newLines[lastNew].dir == lastLines[i].dir &&
                    newLines[lastNew].dir != Direction.DIAGONAL) {
                    newLines[lastNew].x2 = lastLines[i].x2;
                    newLines[lastNew].y2 = lastLines[i].y2;
                    continue;
                }
            }
            newLines += lastLines[i];
        }

        lines = newLines;

        last = lines.length - 1;
        xLast = lines[last].x2;
        yLast = lines[last].y2;
        xLineStart = lines[last].x1;
        yLineStart = lines[last].y1;
        dirLast = lines[last].dir;
    }

    /**
     * Add a point to the path. Returns 1 if a paths should finallise.
     * Returns 2 if a point should be undone.
     */
    public int append(int x, int y, float diagonalThreshold = 0) {
        if (x == xLast && y == yLast) {
            if (x == xLineStart && y == yLineStart) {
                return 2;
            } else {
                return 1;
            }
        }

        int xDiff = x - xLast;
        int yDiff = y - yLast;
        int xDiffAbs = (xDiff > 0) ? xDiff : -xDiff;
        int yDiffAbs = (yDiff > 0) ? yDiff : -yDiff;

        Line[] newLines = lines;

        Line line = Line();
        bool lineAdded = false;

        if (x == xLineStart && y == yLineStart) {
            last --;
            newLines.length --;
            if (last == -1) {
                return 2; // Cancel path / wire.
            } else {
                dirLast = newLines[last].dir;
            }
        } else {
            if (xDiffAbs > yDiffAbs) {
                if ( (float)yDiffAbs < diagonalThreshold * (float)xDiffAbs || y == yLast ) {
                    switch (dirLast) {
                    case Direction.NONE:
                        // Create start line
                        dirLast = Direction.HORIZONTAL;
                        line.x1 = xLast;
                        line.y1 = yLast;
                        line.x2 = x;
                        line.y2 = yLast;
                        lineAdded = true;
                        break;
                    case Direction.HORIZONTAL:
                        // Alter length of last line
                        dirLast = Direction.HORIZONTAL;
                        newLines[last].x2 = x;
                        break;
                    case Direction.VERTICAL:
                        // Alter length of last line, then...
                        newLines[last].y2 = y;
                        // ...new line
                        dirLast = Direction.HORIZONTAL;
                        line.x1 = xLast;
                        line.y1 = y;
                        line.x2 = x;
                        line.y2 = y;
                        lineAdded = true;
                        break;
                    case Direction.DIAGONAL:
                        dirLast = Direction.HORIZONTAL;
                        line.x1 = xLast;
                        line.y1 = yLast;
                        line.x2 = x;
                        line.y2 = yLast;
                        lineAdded = true;
                        break;
                    }
                } else {
                    dirLast = Direction.DIAGONAL;
                    line.x1 = xLast;
                    line.y1 = yLast;
                    line.x2 = x;
                    line.y2 = y;
                    lineAdded = true;
                }
            } else {
                if ( (float)xDiffAbs < diagonalThreshold * (float)yDiffAbs || x == xLast ) {
                    switch (dirLast) {
                    case Direction.NONE:
                        // Create start line
                        dirLast = Direction.VERTICAL;
                        line.x1 = xLast;
                        line.y1 = yLast;
                        line.x2 = xLast;
                        line.y2 = y;
                        lineAdded = true;
                        break;
                    case Direction.VERTICAL:
                        // Alter length of last line
                        dirLast = Direction.VERTICAL;
                        newLines[last].y2 = y;
                        break;
                    case Direction.HORIZONTAL:
                        // Alter length of last line, then...
                        newLines[last].x2 = x;
                        // ...new line
                        dirLast = Direction.VERTICAL;
                        line.x1 = x;
                        line.y1 = yLast;
                        line.x2 = x;
                        line.y2 = y;
                        lineAdded = true;
                        break;
                    case Direction.DIAGONAL:
                        dirLast = Direction.VERTICAL;
                        line.x1 = xLast;
                        line.y1 = yLast;
                        line.x2 = xLast;
                        line.y2 = y;
                        lineAdded = true;
                        break;
                    }
                } else {
                    dirLast = Direction.DIAGONAL;
                    line.x1 = xLast;
                    line.y1 = yLast;
                    line.x2 = x;
                    line.y2 = y;
                    lineAdded = true;
                }
            }

            if (lineAdded) {
                last ++;
                line.dir = dirLast;
                newLines += line;
            }
        }

        xLineStart = newLines[last].x1;
        yLineStart = newLines[last].y1;
        xLast = newLines[last].x2;
        yLast = newLines[last].y2;

        lines = newLines;

        return 0;
    }

    /**
     * Return 1 if the point (//x//, //y//) is on a line between points.
     * Return 2 if the point (//x//, //y//) is on a point.
     * Else return 0.
     */
    public int find(int x, int y) {
        if (last >= 0) {
            if ((x == lines[0].x1 && y == lines[0].y1)
                || (x == lines[last].x2 && y == lines[last].y2)) {
                return 2;
            }
        }
        foreach (Line line in lines) {
            switch (line.dir) {
            case Direction.HORIZONTAL:
                if (y == line.y1 /* and thus y2 */) {
                    if ((line.x1 <= x && x <= line.x2) || (line.x1 >= x && x >= line.x2)) {
                        return 1;
                    }
                }
                break;
            case Direction.VERTICAL:
                if (x == line.x1 /* and thus x2 */) {
                    if ((line.y1 <= y && y <= line.y2) || (line.y1 >= y && y >= line.y2)) {
                        return 1;
                    }
                }
                break;
            case Direction.DIAGONAL:
                int xMin, xMax, yMin, yMax;

                if ( (x == line.x1 && y == line.y1)
                     || (x == line.x2 && y == line.y2) ) {
                    return 2;
                }

                if (line.x1 < line.x2) {
                    xMin = line.x1;
                    xMax = line.x2;
                } else {
                    xMin = line.x2;
                    xMax = line.x1;
                }
                if (line.y1 < line.y2) {
                    yMin = line.y1;
                    yMax = line.y2;
                } else {
                    yMin = line.y2;
                    yMax = line.y1;
                }

                // Bounds check
                if (xMin <= x && x <= xMax  &&  yMin <= y && y <= yMax) {
                    if (line.x1 == line.x2 || line.y1 == line.y2) {
                        break; // Just incase
                    }

                    float xLineDiff = (float)line.x2 - (float)line.x1;
                    float yLineDiff = (float)line.y2 - (float)line.y1;
                    float gradient = yLineDiff / xLineDiff;
                    float gradientAbs = (gradient < 0) ? -gradient : gradient;

                    float diff;
                    float diffAbs;

                    if (gradientAbs < 1) {
                        float yExpected = gradient * ((float)x - (float)line.x1) + (float)line.y1;
                        diff = y - yExpected;
                        diffAbs = (diff < 0) ? -diff : diff;
                    } else {
                        float xExpected = ((float)y - (float)line.y1) / gradient + (float)line.x1;
                        diff = x - xExpected;
                        diffAbs = (diff < 0) ? -diff : diff;
                    }

                    if (diffAbs <= 5) {
                        return 1;
                    }
                }


                break;
            }
        }
        return 0;
    }

    /**
     * Displaces the path by //x// horizontally, and //y// vertically.
     */
    public void move(int x, int y) {
        for (int i = 0; i < lines.length; i++) {
            lines[i].x1 += x;
            lines[i].y1 += y;
            lines[i].x2 += x;
            lines[i].y2 += y;
        }
        xLast += x;
        yLast += y;
        xLineStart += x;
        yLineStart += y;
    }

    /**
     * Renders the path's lines.
     */
    public void render(Cairo.Context context) {
        foreach (Line line in lines) {
            context.move_to(line.x1, line.y1);
            context.line_to(line.x2, line.y2);
            context.stroke();
        }
    }
}
