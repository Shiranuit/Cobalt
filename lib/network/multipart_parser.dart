import 'dart:io';

import 'dart:typed_data';

class MultiPartPart {
  final String? name;
  final String? filename;
  final String? contentType;
  final String? contentDisposition;
  final bool isFile;
  final Uint8List content;

  MultiPartPart({
    required this.content,
    this.name,
    this.filename,
    this.contentType,
    this.contentDisposition,
    this.isFile = false,
  });

  String contentAsString() => String.fromCharCodes(content);
}

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

  static int _parseHeaders(
      List<int> content, Map<String, HeaderValue> headers) {
    int colonChar = ':'.codeUnitAt(0);
    int newlineChar = '\n'.codeUnitAt(0);
    int index = 0;
    while (index < content.length) {
      int start = index;
      String key = '';
      while (index < content.length && content[index] != colonChar) {
        if (content[index] == newlineChar) {
          return index;
        }
        index++;
      }
      if (index >= content.length) {
        return -1;
      }
      key = String.fromCharCodes(content.sublist(start, index));
      int startValue = ++index;
      while (index < content.length && content[index] != newlineChar) {
        index++;
      }
      String value =
          String.fromCharCodes(content.sublist(startValue, index - 1));
      headers[key.toLowerCase()] = HeaderValue.parse(value);
      index++;
    }
    return index;
  }

  static MultiPartPart _parseMultipartPart(List<int> content) {
    Map<String, HeaderValue> headers = {};
    int endHeaders = _parseHeaders(content, headers);

    return MultiPartPart(
      content: Uint8List.fromList(
        content.sublist(endHeaders + 1, content.length - 1),
      ),
      filename: headers['content-disposition']?.parameters['filename'],
      contentType: headers['content-type']?.value,
      contentDisposition: headers['content-disposition']?.value,
      name: headers['content-disposition']?.parameters['name'],
      isFile: headers['content-disposition']?.parameters['filename'] != null,
    );
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
