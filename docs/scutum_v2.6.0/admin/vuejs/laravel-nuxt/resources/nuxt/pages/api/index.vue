<template>
	<ScCard>
		<ScCardBody>
			<table class="uk-table uk-table-divider">
				<tbody>
					<tr v-for="(user, key) in data" :key="key">
						<td class="uk-table-shrink">
							{{ user.id }}
						</td>
						<td class="uk-table-shrink uk-text-nowrap">
							<strong>
								{{ user.name }}
							</strong>
						</td>
						<td>
							{{ user.email }}
						</td>
						<td class="uk-table-shrink">
							<nuxt-link :to="{ name: 'api-id', params: { id: user.id } }" class="sc-button">
								Details
							</nuxt-link>
						</td>
					</tr>
				</tbody>
			</table>
		</ScCardBody>
	</ScCard>
</template>

<script>
export default {
	name: 'ApiIndex',
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
