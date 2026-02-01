<template>
	<div
		class="sc-fab-card-wrapper sc-fab-sheet"
		:class="{
			'sc-fab-animated': animated,
			'sc-fab-active': active
		}"
		:style="[fabStyle]"
	>
		<slot name="trigger"></slot>
		<div ref="actions" class="sc-fab-sheet-actions">
			<slot name="actions"></slot>
		</div>
	</div>
</template>

<script>

export default {
	name: 'ScFabSingleSheet',
	props: {
		actions: {
			type: Number,
			default: 1
		}
	},
	data: () => ({
		fabActive: false,
		animDuration: 80,
		animated: false,
		active: false,
		fabStyle: {
			width: '',
			height: ''
		}
	}),
	mounted () {
		const self = this
		window.addEventListener('click', function (e) {
			if(!e.target.closest('.sc-fab-sheet')) {
				self.hide()
			}
		});
	},
	methods: {
		show: function () {
			const self = this
			this.animated = true;
			setTimeout(() => {
				self.fabStyle.width = '240px'
				self.fabStyle.height = `${self.actions*40 + 8}px`
			}, 140);
			setTimeout( () => {
				this.active = true
			}, 280);
		},
		hide: function () {
			const self = this
			if(this.active) {
				this.active = false
				self.fabStyle.width = ''
				self.fabStyle.height = ''
				setTimeout( () => {
					this.animated = false;
				}, 140);
			}
		}
	}
}
</script>
