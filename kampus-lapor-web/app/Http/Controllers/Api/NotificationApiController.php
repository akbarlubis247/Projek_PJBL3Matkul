<?php

namespace App\Http\Controllers\Api;

class NotificationApiController extends BaseApiController
{
    public function notifications()
    {
        return response()->json(['data' => []]);
    }

    public function notificationRead(string $id)
    {
        return response()->json(['success' => true, 'id' => $id]);
    }
}
