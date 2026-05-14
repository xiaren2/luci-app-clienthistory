#!/usr/bin/env ucode

'use strict';

import { readfile, writefile } from 'fs';

const HISTORY_FILE = '/var/lib/clienthistory/history.json';

const methods = {
	getHistory: {
		call: function() {
			let content = readfile(HISTORY_FILE);
			if (content == null)
				return { history: {} };

			try {
				return { history: json(content) || {} };
			}
			catch (e) {
				return { history: {} };
			}
		}
	},

	clearHistory: {
		call: function() {
			writefile(HISTORY_FILE, '{}');
			return { result: true };
		}
	}
};

return { 'luci.clienthistory': methods };
