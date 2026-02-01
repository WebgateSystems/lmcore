<template>
	<div id="sc-page-wrapper">
		<div id="sc-page-content" class="uk-flex uk-flex-center">
			<div class="uk-width-5-6@m">
				<div class="uk-card uk-height-1-1 uk-flex uk-flex-column">
					<div class="uk-card-body sc-padding-remove uk-flex-1">
						<div class="sc-padding">
							<h2>Boxed layout</h2>
							<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Delectus deserunt doloremque enim error eveniet fugiat incidunt magnam nisi omnis placeat praesentium reprehenderit rerum, sequi ut veniam voluptates, voluptatibus! Accusamus animi cupiditate dicta dolore enim eum ex explicabo fuga illo libero minima nobis officia perferendis quae quis, sit voluptatum. Aliquam amet atque debitis dolore eius ex hic id illo impedit inventore ipsam labore maxime nihil, nisi non nostrum omnis provident quas quasi, qui quisquam ratione reiciendis temporibus voluptas voluptatibus. Accusamus consequuntur corporis, deleniti deserunt dolore doloremque ea eos eum explicabo, illum laborum modi nostrum optio quos sequi suscipit temporibus totam vel.</p>
							<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Delectus deserunt doloremque enim error eveniet fugiat incidunt magnam nisi omnis placeat praesentium reprehenderit rerum, sequi ut veniam voluptates, voluptatibus! Accusamus animi cupiditate dicta dolore enim eum ex explicabo fuga illo libero minima nobis officia perferendis quae quis, sit voluptatum. Aliquam amet atque debitis dolore eius ex hic id illo impedit inventore ipsam labore maxime nihil, nisi non nostrum omnis provident quas quasi, qui quisquam ratione reiciendis temporibus voluptas voluptatibus. Accusamus consequuntur corporis, deleniti deserunt dolore doloremque ea eos eum explicabo, illum laborum modi nostrum optio quos sequi suscipit temporibus totam vel.</p>
							<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Delectus deserunt doloremque enim error eveniet fugiat incidunt magnam nisi omnis placeat praesentium reprehenderit rerum, sequi ut veniam voluptates, voluptatibus! Accusamus animi cupiditate dicta dolore enim eum ex explicabo fuga illo libero minima nobis officia perferendis quae quis, sit voluptatum. Aliquam amet atque debitis dolore eius ex hic id illo impedit inventore ipsam labore maxime nihil, nisi non nostrum omnis provident quas quasi, qui quisquam ratione reiciendis temporibus voluptas voluptatibus. Accusamus consequuntur corporis, deleniti deserunt dolore doloremque ea eos eum explicabo, illum laborum modi nostrum optio quos sequi suscipit temporibus totam vel.</p>
							<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Delectus deserunt doloremque enim error eveniet fugiat incidunt magnam nisi omnis placeat praesentium reprehenderit rerum, sequi ut veniam voluptates, voluptatibus! Accusamus animi cupiditate dicta dolore enim eum ex explicabo fuga illo libero minima nobis officia perferendis quae quis, sit voluptatum. Aliquam amet atque debitis dolore eius ex hic id illo impedit inventore ipsam labore maxime nihil, nisi non nostrum omnis provident quas quasi, qui quisquam ratione reiciendis temporibus voluptas voluptatibus. Accusamus consequuntur corporis, deleniti deserunt dolore doloremque ea eos eum explicabo, illum laborum modi nostrum optio quos sequi suscipit temporibus totam vel.</p>
							<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Delectus deserunt doloremque enim error eveniet fugiat incidunt magnam nisi omnis placeat praesentium reprehenderit rerum, sequi ut veniam voluptates, voluptatibus! Accusamus animi cupiditate dicta dolore enim eum ex explicabo fuga illo libero minima nobis officia perferendis quae quis, sit voluptatum. Aliquam amet atque debitis dolore eius ex hic id illo impedit inventore ipsam labore maxime nihil, nisi non nostrum omnis provident quas quasi, qui quisquam ratione reiciendis temporibus voluptas voluptatibus. Accusamus consequuntur corporis, deleniti deserunt dolore doloremque ea eos eum explicabo, illum laborum modi nostrum optio quos sequi suscipit temporibus totam vel.</p>
							<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Delectus deserunt doloremque enim error eveniet fugiat incidunt magnam nisi omnis placeat praesentium reprehenderit rerum, sequi ut veniam voluptates, voluptatibus! Accusamus animi cupiditate dicta dolore enim eum ex explicabo fuga illo libero minima nobis officia perferendis quae quis, sit voluptatum. Aliquam amet atque debitis dolore eius ex hic id illo impedit inventore ipsam labore maxime nihil, nisi non nostrum omnis provident quas quasi, qui quisquam ratione reiciendis temporibus voluptas voluptatibus. Accusamus consequuntur corporis, deleniti deserunt dolore doloremque ea eos eum explicabo, illum laborum modi nostrum optio quos sequi suscipit temporibus totam vel.</p>
							<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Delectus deserunt doloremque enim error eveniet fugiat incidunt magnam nisi omnis placeat praesentium reprehenderit rerum, sequi ut veniam voluptates, voluptatibus! Accusamus animi cupiditate dicta dolore enim eum ex explicabo fuga illo libero minima nobis officia perferendis quae quis, sit voluptatum. Aliquam amet atque debitis dolore eius ex hic id illo impedit inventore ipsam labore maxime nihil, nisi non nostrum omnis provident quas quasi, qui quisquam ratione reiciendis temporibus voluptas voluptatibus. Accusamus consequuntur corporis, deleniti deserunt dolore doloremque ea eos eum explicabo, illum laborum modi nostrum optio quos sequi suscipit temporibus totam vel.</p>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</template>

<script>
export default {
	name: 'LayoutBoxed',
	mounted () {
		this.$store.commit('toggleLayoutBoxed', true);
	},
	beforeDestroy () {
		this.$store.commit('toggleLayoutBoxed', false);
	}
}
</script>
