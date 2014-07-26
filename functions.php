<?php

/**
 * Don't allow the theme to be loaded directly
 */
if ( ! function_exists( 'add_action' ) ) {
	echo "Please enable this theme from the WordPress admin area.";
	exit;
}

/**
 * Initialize Composer Autoload. Check php version
 */
if ( file_exists( dirname( __FILE__ ) . '/vendor/autoload.php' ) && version_compare( phpversion(), '5.3', '>=' ) )
	require_once( dirname( __FILE__ ) . '/vendor/autoload.php' );


/**
 * Initialize WordPress plugin
 */
if( class_exists( 'BWSkeletonTheme\\Plugin' ) )
	\BWSkeletonTheme\Plugin::init( __FILE__ );
