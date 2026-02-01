<div id="sc-page-wrapper">
    <div id="sc-page-top-bar" class="sc-top-bar">
        <div class="sc-top-bar-content uk-flex uk-flex-middle uk-flex-1">
            <div>
                <input type="radio" id="sc-diff-chars" name="sc-diff" data-sc-icheck value="diffChars">
                <label for="sc-diff-chars">Chars</label>
            </div>
            <div class="<?php rtlReplace('uk-margin-medium-left', 'uk-margin-medium-right'); ?>">
                <input type="radio" id="sc-diff-words" name="sc-diff" value="diffWords" data-sc-icheck>
                <label for="sc-diff-words">Words</label>
            </div>
            <div class="<?php rtlReplace('uk-margin-medium-left', 'uk-margin-medium-right'); ?>">
                <input type="radio" id="sc-diff-lines" name="sc-diff" value="diffLines" data-sc-icheck checked>
                <label for="sc-diff-lines">Lines</label>
            </div>
        </div>
    </div>
	<div id="sc-page-content">
        <div class="uk-card">
            <div class="uk-overflow-auto">

                <div class="uk-child-width-1-2@s uk-child-width-1-3@l uk-grid-collapse uk-grid-divider" data-uk-grid>
                    <div>
                        <div class="sc-padding sc-padding-medium-ends">
                        <p>Panel A</p>
<textarea name="sc-diff-panel-1" id="sc-diff-panel-a" cols="30" rows="20" class="uk-textarea sc-js-autosize" data-sc-input="outline" dir="ltr">
export function parsePatch(uniDiff, options = {}) {
  let diffstr = uniDiff.split('\n'),
      list = [],
      i = 0;

  function parseIndex() {
    let index = {};
    list.push(index);

    // Ignore any leading junk
    while (i < diffstr.length) {
      if (/^(Index:|diff -r|@@)/.test(diffstr[i])) {
        break;
      }
      i++;
    }

    let header = (/^(?:Index:|diff(?: -r \w+)+) (.*)/.exec(diffstr[i]));
    if (header) {
      index.index = header[1];
      i++;

      if (/^===/.test(diffstr[i])) {
        i++;
      }

      parseFileHeader(index);
      parseFileHeader(index);
    } else {
      // Ignore erant header components that might occur at the start of the file
      parseFileHeader({});
      parseFileHeader({});
    }

    index.hunks = [];

    while (i < diffstr.length) {
      if (/^(Index:|diff -r)/.test(diffstr[i])) {
        break;
      } else if (/^@@/.test(diffstr[i])) {
        index.hunks.push(parseHunk());
      } else if (diffstr[i] && options.strict) {
        // Ignore unexpected content unless in strict mode
        throw new Error('Unknown line ' + (i + 1) + ' ' + JSON.stringify(diffstr[i]));
      } else {
        i++;
      }
    }
  }

  // Parses the --- and +++ headers, if none are found, no lines
  // are consumed.
  function parseFileHeader(index) {
    let fileHeader = (/^(\-\-\-|\+\+\+)\s(\S+)\s?(.*)/.exec(diffstr[i]));
    if (fileHeader) {
      let keyPrefix = fileHeader[1] === '---' ? 'old' : 'new';
      index[keyPrefix + 'FileName'] = fileHeader[2];
      index[keyPrefix + 'Header'] = fileHeader[3];

      i++;
    }
  }

  // Parses a hunk
  // This assumes that we are at the start of a hunk.
  function parseHunk() {
    let chunkHeaderIndex = i,
        chunkHeaderLine = diffstr[i++],
        chunkHeader = chunkHeaderLine.split(/@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@/);

    let hunk = {
      oldStart: +chunkHeader[1],
      oldLines: +chunkHeader[2] || 1,
      newStart: +chunkHeader[3],
      newLines: +chunkHeader[4] || 1,
      lines: []
    };

    let addCount = 0,
        removeCount = 0;
    for (; i < diffstr.length; i++) {
      let operation = diffstr[i][0];

      if (operation === '+' || operation === '-' || operation === ' ' || operation === '\\') {
        hunk.lines.push(diffstr[i]);

        if (operation === '+') {
          addCount++;
        } else if (operation === '-') {
          removeCount++;
        } else if (operation === ' ') {
          addCount++;
          removeCount++;
        }
      } else {
        break;
      }
    }

    return hunk;
  }

  while (i < diffstr.length) {
    parseIndex();
  }

  return list;
}
</textarea>
                        </div>
                    </div>
                    <div>
                        <div class="sc-padding sc-padding-medium-ends">
                        <p>Panel B</p>
<textarea name="sc-diff-panel-2" id="sc-diff-panel-b" cols="30" rows="20" class="uk-textarea sc-js-autosize" data-sc-input="outline" dir="ltr">
export function parsePatch(uniDiff, options = {}) {
  let diffstr = uniDiff.split(/\r\n|[\n\v\f\r\x85]/),
      delimiters = uniDiff.match(/\r\n|[\n\v\f\r\x85]/g) || [],
      list = [],
      i = 0;

  function parseIndex() {
    let index = {};
    list.push(index);

    // Parse diff metadata
    while (i < diffstr.length) {
      let line = diffstr[i];

      // File header found, end parsing diff metadata
      if (/^(\-\-\-|\+\+\+|@@)\s/.test(line)) {
        break;
      }

      // Diff index
      let header = (/^(?:Index:|diff(?: -r \w+)+)\s+(.+?)\s*$/).exec(line);
      if (header) {
        index.index = header[1];
      }

      i++;
    }

    // Parse file headers if they are defined. Unified diff requires them, but
    // there's no technical issues to have an isolated hunk without file header
    parseFileHeader(index);
    parseFileHeader(index);

    // Parse hunks
    index.hunks = [];

    while (i < diffstr.length) {
      let line = diffstr[i];

      if (/^(Index:|diff|\-\-\-|\+\+\+)\s/.test(line)) {
        break;
      } else if (/^@@/.test(line)) {
        index.hunks.push(parseHunk());
      } else if (line && options.strict) {
        // Ignore unexpected content unless in strict mode
        throw new Error('Unknown line ' + (i + 1) + ' ' + JSON.stringify(line));
      } else {
        i++;
      }
    }
  }

  // Parses the --- and +++ headers, if none are found, no lines
  // are consumed.
  function parseFileHeader(index) {
    const fileHeader = (/^(---|\+\+\+)\s+(.*)$/).exec(diffstr[i]);
    if (fileHeader) {
      let keyPrefix = fileHeader[1] === '---' ? 'old' : 'new';
      const data = fileHeader[2].split('\t', 2);
      let fileName = data[0].replace(/\\\\/g, '\\');
      if (/^".*"$/.test(fileName)) {
        fileName = fileName.substr(1, fileName.length - 2);
      }
      index[keyPrefix + 'FileName'] = fileName;
      index[keyPrefix + 'Header'] = (data[1] || '').trim();

      i++;
    }
  }

  // Parses a hunk
  // This assumes that we are at the start of a hunk.
  function parseHunk() {
    let chunkHeaderIndex = i,
        chunkHeaderLine = diffstr[i++],
        chunkHeader = chunkHeaderLine.split(/@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@/);

    let hunk = {
      oldStart: +chunkHeader[1],
      oldLines: +chunkHeader[2] || 1,
      newStart: +chunkHeader[3],
      newLines: +chunkHeader[4] || 1,
      lines: [],
      linedelimiters: []
    };

    let addCount = 0,
        removeCount = 0;
    for (; i < diffstr.length; i++) {
      // Lines starting with '---' could be mistaken for the "remove line" operation
      // But they could be the header for the next file. Therefore prune such cases out.
      if (diffstr[i].indexOf('--- ') === 0
            && (i + 2 < diffstr.length)
            && diffstr[i + 1].indexOf('+++ ') === 0
            && diffstr[i + 2].indexOf('@@') === 0) {
          break;
      }
      let operation = (diffstr[i].length == 0 && i != (diffstr.length - 1)) ? ' ' : diffstr[i][0];

      if (operation === '+' || operation === '-' || operation === ' ' || operation === '\\') {
        hunk.lines.push(diffstr[i]);
        hunk.linedelimiters.push(delimiters[i] || '\n');

        if (operation === '+') {
          addCount++;
        } else if (operation === '-') {
          removeCount++;
        } else if (operation === ' ') {
          addCount++;
          removeCount++;
        }
      } else {
        break;
      }
    }

    return hunk;
  }

  while (i < diffstr.length) {
    parseIndex();
  }

  return list;
}
</textarea>
                        </div>
                    </div>
                    <div>
                        <div class="sc-padding sc-padding-medium-ends">
                            <p>Result</p>
                            <pre id="sc-diff-result" dir="ltr"></pre>
                        </div>
                    </div>
                </div>
            </div>
        </div>
	</div>
</div>
