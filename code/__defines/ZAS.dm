
/*
	Uncomment this to enable ZAS debugging tools. While ghosted, you will see a visualization of the atmos status of turfs.
	Green turfs are zones that are existing happily.
	Yellow-orange turfs are a zone that has recently been merged into another zone.
	Red turfs are turfs are an invalidated zone. Invalid zones are zones that were destroyed.
	White/overlay-less turfs are turfs that are the origin point of a zone. This is completely useless information.
	Purple outlines indicate the turf was marked for an update by SSair, and is in its processing list.
	In addition, all ZAS-related datums and turfs will have a "verbose" var. Set this to 1 using View Variables to get robust to_chat()s about activity.
	Finally, this is a friendly reminder that using Debug Verbs gives access to the Zone Info and Test ZAS Connection verbs when you right click a turf.

	Addendum:
		There are additional debug overlays that use ZAS_ZONE_BLOCKER and ZAS_DIRECTIONAL_BLOCKER.
		They take priority over standard overlays, displaying directional airflow, and are generally not needed so they are commented out by default.
*/
//#define ZASDBG
#define MULTIZAS

#define AIR_BLOCKED 1
#define ZONE_BLOCKED 2
#define BLOCKED 3

/// Zones with less than this many turfs will always merge, even if the connection is not direct.
#define ZONE_MIN_SIZE 14

#define CANPASS_ALWAYS 1
#define CANPASS_DENSITY 2
#define CANPASS_PROC 3
#define CANPASS_NEVER 4

#define NORTHUP (NORTH|UP)
#define EASTUP (EAST|UP)
#define SOUTHUP (SOUTH|UP)
#define WESTUP (WEST|UP)
#define NORTHDOWN (NORTH|DOWN)
#define EASTDOWN (EAST|DOWN)
#define SOUTHDOWN (SOUTH|DOWN)
#define WESTDOWN (WEST|DOWN)

#define TURF_HAS_VALID_ZONE(T) (isturf(T) && T:zone && !T:zone:invalid)
#define SHOULD_PARTICIPATE_IN_ZONES(T) (isturf(T) && T:zone_membership_candidate && (!T:external_atmosphere_participation || !T:is_outside()))

#define ATMOS_CANPASS_MOVABLE(ret, AM, TARG_TURF) \
	switch (AM.atmos_canpass) { \
		if (CANPASS_ALWAYS) { EMPTY_BLOCK_GUARD } \
		if (CANPASS_DENSITY) { \
			if (AM.density) { \
				ret |= AIR_BLOCKED; \
			} \
		} \
		if (CANPASS_PROC) { \
			ret |= (AIR_BLOCKED * !AM.CanPass(null, TARG_TURF, 0, 0)) | (ZONE_BLOCKED * !AM.CanPass(null, TARG_TURF, 1.5, 1)); \
		} \
		if (CANPASS_NEVER) { \
			ret = BLOCKED; \
		} \
	}

#ifdef MULTIZAS
#define ZAS_CSRFZ_CHECK global.cornerdirsz
#define ZAS_GZN_CHECK global.cardinalz

#define ATMOS_CANPASS_TURF(ret, A, B) \
	if (A.blocks_air & AIR_BLOCKED || B.blocks_air & AIR_BLOCKED) { \
		ret = BLOCKED; \
	} \
	else if (B.z < A.z) { \
		ret = (A.z_flags & ZM_ALLOW_ATMOS) ? ZONE_BLOCKED : BLOCKED; \
	} \
	else if(B.z > A.z) { \
		ret = (B.z_flags & ZM_ALLOW_ATMOS) ? ZONE_BLOCKED : BLOCKED; \
	} \
	else if ((A.blocks_air & ZONE_BLOCKED) || (B.blocks_air & ZONE_BLOCKED)) { \
		ret = ZONE_BLOCKED; \
	} \
	else if (length(A.contents)) { \
		ret = 0;\
		for (var/atom/movable/AM as anything in A) { \
			ATMOS_CANPASS_MOVABLE(ret, AM, B); \
			if (ret == BLOCKED) { \
				break;\
			}\
		}\
	}
#else

#define ZAS_CSRFZ_CHECK global.cornerdirs
#define ZAS_GZN_CHECK global.cardinal

#define ATMOS_CANPASS_TURF(ret, A, B) \
	if (A.blocks_air & AIR_BLOCKED || B.blocks_air & AIR_BLOCKED) { \
		ret = BLOCKED; \
	} \
	else if (A.blocks_air & ZONE_BLOCKED || B.blocks_air & ZONE_BLOCKED) { \
		ret = ZONE_BLOCKED; \
	} \
	else if (length(A.contents)) { \
		ret = 0;\
		for (var/thing in A) { \
			var/atom/movable/AM = thing; \
			ATMOS_CANPASS_MOVABLE(ret, AM, B); \
			if (ret == BLOCKED) { \
				break;\
			}\
		}\
	}

#endif

#define GAS_STANDARD_AIRMIX "STANDARD_AIRMIX"