package com.zerotechiot.eg

import com.thingclips.smart.commonbiz.bizbundle.family.api.AbsBizBundleFamilyService


class BizBundleFamilyServiceImpl : AbsBizBundleFamilyService() {
    private var mHomeId: Long = 0

    override fun getCurrentHomeId(): Long {
        return mHomeId
    }

    override fun shiftCurrentFamily(familyId: Long, curName: String?) {
        super.shiftCurrentFamily(familyId, curName)
        mHomeId = familyId
    }
}
