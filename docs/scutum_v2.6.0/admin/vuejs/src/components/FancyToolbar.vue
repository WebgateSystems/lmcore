<template>
	<header id="sc-fancy-toolbar">
		<nav>
			<ul id="fancy-toolbar-switcher" ref="list" class="sc-ft-list">
				<li
					v-for="(item, index) in listItems"
					:key="item.id"
					:style="{'--item-bg': item.color}"
					:title="item.title"
					:class="{
						'uk-active': item.active
					}"
					@click.prevent="toggleItem(item, index)"
				>
					<a href="javascript:void(0)">
						<i class="mdi" :class="[`mdi-${item.icon}`]"></i>
					</a>
				</li>
			</ul>
			<div class="sc-ft-wave-wrap">
				<svg version="1.1"
					class="sc-ft-wave"
					xmlns="http://www.w3.org/2000/svg"
					xmlns:xlink="http://www.w3.org/1999/xlink"
					viewBox="0 0 119 26"
					:style="waveStyle"
				>
					<path class="path" d="M120.8,26C98.1,26,86.4,0,60.4,0C35.9,0,21.1,26,0.5,26H120.8z" />
				</svg>
			</div>
		</nav>
	</header>
</template>

<script>
import { uniqueID } from '~/assets/js/utils/helpers'
import { offset, width } from '~/assets/js/utils/dom'

export default {
	data: () => ({
		listItems: [
			{
				id: uniqueID(),
				title: 'Home',
				color: '#3F51B5',
				icon: 'home',
				active: false
			},
			{
				id: uniqueID(),
				title: 'Profile',
				color: '#009688',
				icon: 'account',
				active: false
			},
			{
				id: uniqueID(),
				title: 'Email',
				color: '#FF9800',
				icon: 'email-outline',
				active: true
			},
			{
				id: uniqueID(),
				title: 'Files',
				color: '#9C27B0',
				icon: 'image-frame',
				active: false
			},
			{
				id: uniqueID(),
				title: 'Settings',
				color: '#00BCD4',
				icon: 'settings',
				active: false
			}
		],
		waveStyle: {
			left: 0
		},
		activeIndex: 0
	}),
	watch: {
		'activeIndex' (newIndex) {
			if (newIndex > -1) {
				this.alignWave(newIndex)
			}
		},
		'listItems': {
			deep: true,
			handler (items) {
				const index = items.map(item => item.active).indexOf(true)
				if(index > -1) {
					this.activeIndex = index
					UIkit.switcher('#fancy-toolbar-switcher').show(index)
				}
			}
		}
	},
	mounted () {
		this.$nextTick(() => {
			const self = this
			const index = this.listItems.map(item => item.active).indexOf(true)
			if (index) {
				// align wave on page load
				this.activeIndex = index
				// init switcher
				UIkit.switcher('#fancy-toolbar-switcher', {
					connect: '#fancy-toolbar-switcher-items',
					animation: 'uk-animation-slide-bottom-medium',
					active: index
				});
			}
			window.matchMedia('(orientation: portrait)').addEventListener( "change", (e) => {
				if (e.matches) {
					setTimeout(function () {
						const index = self.listItems.map(item => item.active).indexOf(true)
						self.alignWave(index)
					}, 400)
				}
			})
			window.matchMedia('(orientation: landscape)').addEventListener( "change", (e) => {
				if (e.matches) {
					setTimeout(function () {
						const index = self.listItems.map(item => item.active).indexOf(true)
						self.alignWave(index)
					}, 400)
				}
			})
		})
	},
	methods: {
		toggleItem (item, index) {
			this.listItems.forEach((item, i) => {
				item.active = (i === index)
			})
			this.activeIndex = index
		},
		alignWave (index) {
			const item = this.$refs.list.childNodes[index]
			const itemWidth = width(item)
			const itemPosLeft = offset(item, true).left
			this.waveStyle.left = `${itemPosLeft.toFixed(2) - itemWidth/2 - 4}px`
		}
	}
}
</script>

<style lang="scss">
	@import "~scss/common/variables_mixins";
	@import "~scss/partials/fancy_toolbar";
</style>
