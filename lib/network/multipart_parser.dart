class MultiPartPart {}

class MultiPartParser {
  static int find(List<int> boundary, int start, List<int> content) {
    int strIndex = 0;
    int index = start;
    while (index < content.length) {
      if (content[index] == boundary[strIndex]) {
        strIndex++;
        if (strIndex == boundary.length) {
          return index - boundary.length + 1;
        }
      } else {
        strIndex = 0;
      }
      index++;
    }
    return -1;
  }

  static MultiPartPart _parseMultipartPart(List<int> content) {
    return MultiPartPart();
  }

  static List<MultiPartPart> parse(String boundary, List<int> content) {
    List<MultiPartPart> parts = [];
    List<int> boundaryBytes = boundary.codeUnits;

    int index = find(boundaryBytes, 0, content);
    if (index < 0) {
      return parts;
    }

    index += boundaryBytes.length + 1;

    while (index < content.length) {
      int boundaryIndex = find(boundaryBytes, index, content);
      if (boundaryIndex == -1) {
        break;
      }

      int partStart = index + 1;
      int partEnd = boundaryIndex - 1;
      parts.add(_parseMultipartPart(content.sublist(partStart, partEnd)));
      index = boundaryIndex + boundaryBytes.length + 1;
    }

    return parts;
  }
}
