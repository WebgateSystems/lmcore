<template>
	<div id="sc-page-wrapper">
		<div id="sc-page-content">
			<nuxt-child></nuxt-child>
		</div>
	</div>
</template>

<script>
export default {
	name: 'Api',
	async asyncData ({ app, params, error }) {
		try {
		    const id = params.id || '';
		    const user = await app.$axios.$get(`api/users/${id}`);
		    return { user };
		} catch (e) {
		    const response = e.response;
			error({ statusCode: response.status, message: response.status === 404 ? 'Api url not found.' : response.statusText });
		}
	},
	methods: {
	    isObject (obj) {
	        return typeof obj === 'object'
		}
	}
};
</script>
