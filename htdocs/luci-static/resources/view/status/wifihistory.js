'use strict';
'require view';
'require poll';
'require rpc';
'require ui';

const callGetHistory = rpc.declare({
	object: 'luci.wifihistory',
	method: 'getHistory',
	expect: { history: {} }
});

const callClearHistory = rpc.declare({
	object: 'luci.wifihistory',
	method: 'clearHistory',
	expect: { result: true }
});

function formatDate(epoch) {
	if (!epoch || epoch <= 0)
		return '-';
	return new Date(epoch * 1000).toLocaleString();
}

return view.extend({

	currentFilter: 'all',

	load() {
		return callGetHistory();
	},

	updateTable(table, history) {
		let stations = Object.values(history);

		if (this.currentFilter !== 'all')
			stations = stations.filter(s => s.type === this.currentFilter);

		stations.sort((a, b) => {
			if (a.connected !== b.connected)
				return a.connected ? -1 : 1;
			return (b.last_seen || 0) - (a.last_seen || 0);
		});

		const rows = [];

		for (const s of stations) {

			/* ✅ 主机名 */
			let host = s.hostname || '-';

			/* ✅ IPv4 / IPv6 合并 */
			let ip = '';
			if (s.ipv4 && s.ipv6)
				ip = '%s / %s'.format(s.ipv4, s.ipv6);
			else if (s.ipv4)
				ip = s.ipv4;
			else if (s.ipv6)
				ip = s.ipv6;
			else
				ip = '-';

			let icon =
				s.type === 'ethernet'
					? L.resource('icons/ethernet.svg')
					: L.resource('icons/signal-075-100.svg');

			let signal =
				s.type === 'wifi' && s.signal
					? '%d dBm'.format(s.signal)
					: '-';

			let network =
				s.type === 'ethernet'
					? s.ifname || 'LAN'
					: s.network || '-';

			rows.push([
				E('span', {}, [
					E('img', {
						src: icon,
						style: 'width:16px;height:16px'
					})
				]),

				E('span', {
					'class': 'ifacebadge',
					'style': s.connected ? '' : 'opacity:0.5'
				}, [
					s.connected ? _('Yes') : _('No')
				]),

				s.mac,
				host,
				ip,
				network,
				signal,
				formatDate(s.first_seen),
				formatDate(s.last_seen)
			]);
		}

		cbi_update_table(
			table,
			rows,
			E('em', _('No client history available'))
		);
	},

	handleClearHistory() {
		return ui.showModal(_('Clear History'), [
			E('p', _('This will permanently delete all recorded client history.')),
			E('div', { 'class': 'right' }, [
				E('button', { 'class': 'btn', 'click': ui.hideModal }, _('Cancel')),
				' ',
				E('button', {
					'class': 'btn cbi-button-negative',
					'click': ui.createHandlerFn(this, () => {
						return callClearHistory().then(() => {
							ui.hideModal();
							return callGetHistory().then(h => {
								this.updateTable('#wifi_history_table', h);
							});
						});
					})
				}, _('Clear'))
			])
		]);
	},

	setFilter(filter) {
		this.currentFilter = filter;
		return callGetHistory().then(h => {
			this.updateTable('#wifi_history_table', h);
		});
	},

	render(history) {
		const v = E([], [
			E('h2', _('Client History')),
			E('div', { 'class': 'cbi-map-descr' },
				_('Displays WiFi and Ethernet client history.')),

			E('div', { 'style': 'margin-bottom:10px' }, [
				E('button', { 'class': 'btn', 'click': () => this.setFilter('all') }, _('All')),
				' ',
				E('button', { 'class': 'btn', 'click': () => this.setFilter('wifi') }, _('WiFi')),
				' ',
				E('button', { 'class': 'btn', 'click': () => this.setFilter('ethernet') }, _('Ethernet')),
				' ',
				E('button', {
					'class': 'btn cbi-button-negative',
					'click': ui.createHandlerFn(this, 'handleClearHistory')
				}, _('Clear History'))
			]),

			E('table', { 'class': 'table', 'id': 'wifi_history_table' }, [
				E('tr', { 'class': 'tr table-titles' }, [
					E('th', {}, _('Type')),
					E('th', {}, _('Connected')),
					E('th', {}, _('MAC')),
					E('th', {}, _('Host')),
					E('th', {}, _('IP')),
					E('th', {}, _('Network')),
					E('th', {}, _('Signal')),
					E('th', {}, _('First Seen')),
					E('th', {}, _('Last Seen'))
				])
			])
		]);

		this.updateTable('#wifi_history_table', history);

		poll.add(() => {
			return callGetHistory().then(h => {
				this.updateTable('#wifi_history_table', h);
			});
		}, 5);

		return v;
	}
});
