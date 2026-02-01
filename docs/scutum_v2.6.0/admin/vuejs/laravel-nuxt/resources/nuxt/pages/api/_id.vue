<template>
	<ScCard>
		<ScCardBody>
			<table v-if="isObject(data)" class="uk-table uk-table-divider">
				<tbody>
					<tr v-for="(user, key) in data" :key="key">
						<td>{{ key }}</td>
						<td>
							{{ user }}
						</td>
					</tr>
				</tbody>
			</table>
			<div v-else>
				{{ data }}
			</div>
			<div class="uk-margin-top">
				<nuxt-link to="/api" class="sc-button">
					Back
				</nuxt-link>
			</div>
		</ScCardBody>
	</ScCard>
</template>

<script>
export default {
	name: 'ApiId',
	async asyncData ({ app, params, error }) {
		try {
			const id = params.id || '';
			const data = await app.$axios.$get(`api/users/${id}`);
			return { data };
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
